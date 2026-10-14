package com.example.ui.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.data.api.PostApiService
import com.example.data.local.AppDatabase
import com.example.data.local.FavoriteEntity
import com.example.data.model.CreatePostRequest
import com.example.data.model.Post
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

import com.example.util.EnglishTranslator

sealed interface PostsUiState {
    data object Loading : PostsUiState
    data class Success(val posts: List<Post>) : PostsUiState
    data class Error(val message: String) : PostsUiState
}

class PostViewModel(application: Application) : AndroidViewModel(application) {

    private val apiService = PostApiService.create()
    private val favoriteDao = AppDatabase.getInstance(application).favoriteDao()

    private val _postsState = MutableStateFlow<PostsUiState>(PostsUiState.Loading)
    val postsState: StateFlow<PostsUiState> = _postsState.asStateFlow()

    val favorites: StateFlow<List<FavoriteEntity>> = favoriteDao.getAllFavorites()
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )

    private val _snackbarEvent = MutableSharedFlow<String>()
    val snackbarEvent: SharedFlow<String> = _snackbarEvent.asSharedFlow()

    private val _isSubmittingPost = MutableStateFlow(false)
    val isSubmittingPost: StateFlow<Boolean> = _isSubmittingPost.asStateFlow()

    // Local in-memory list to instantly display created posts along with fetched ones
    private val localPosts = mutableListOf<Post>()

    init {
        fetchPosts()
    }

    fun fetchPosts() {
        viewModelScope.launch {
            _postsState.value = PostsUiState.Loading
            try {
                val response = apiService.getPosts()
                if (response.isSuccessful && response.code() == 200) {
                    val posts = response.body() ?: emptyList()
                    val englishPosts = posts.map { EnglishTranslator.toEnglish(it) }
                    localPosts.clear()
                    localPosts.addAll(englishPosts)
                    _postsState.value = PostsUiState.Success(localPosts.toList())
                } else {
                    _postsState.value = PostsUiState.Error(
                        "Server returned status ${response.code()}: ${response.message()}"
                    )
                }
            } catch (e: Exception) {
                _postsState.value = PostsUiState.Error(
                    "Network error: ${e.localizedMessage ?: "Failed to connect to JSONPlaceholder API"}"
                )
            }
        }
    }

    fun createPost(title: String, body: String, onDone: (Boolean) -> Unit) {
        viewModelScope.launch {
            _isSubmittingPost.value = true
            try {
                val request = CreatePostRequest(title = title.trim(), body = body.trim())
                val response = apiService.createPost(request)
                if (response.code() == 201) {
                    val created = response.body() ?: Post(
                        id = (localPosts.maxOfOrNull { it.id } ?: 100) + 1,
                        title = title.trim(),
                        body = body.trim()
                    )
                    localPosts.add(0, created)
                    _postsState.value = PostsUiState.Success(localPosts.toList())
                    _snackbarEvent.emit("Post created successfully! (Status 201)")
                    onDone(true)
                } else {
                    _snackbarEvent.emit("Failed to create post (Status ${response.code()})")
                    onDone(false)
                }
            } catch (e: Exception) {
                _snackbarEvent.emit("Error submitting post: ${e.localizedMessage ?: "Unknown error"}")
                onDone(false)
            } finally {
                _isSubmittingPost.value = false
            }
        }
    }

    fun saveToFavorites(post: Post) {
        viewModelScope.launch {
            val existing = favoriteDao.getFavoriteById(post.id)
            if (existing != null) {
                _snackbarEvent.emit("Post #${post.id} is already in Favorites!")
            } else {
                favoriteDao.insertFavorite(
                    FavoriteEntity(
                        id = post.id,
                        title = post.title,
                        body = post.body,
                        personalNote = ""
                    )
                )
                _snackbarEvent.emit("Post #${post.id} saved to Favorites!")
            }
        }
    }

    fun isFavorite(postId: Int): Boolean {
        return favorites.value.any { it.id == postId }
    }

    fun updateFavoriteNote(id: Int, note: String) {
        viewModelScope.launch {
            favoriteDao.updateNote(id, note.trim())
            _snackbarEvent.emit("Note updated for post #$id")
        }
    }

    fun deleteFavorite(id: Int) {
        viewModelScope.launch {
            favoriteDao.deleteById(id)
            _snackbarEvent.emit("Post #$id removed from Favorites")
        }
    }
}
