package com.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.example.data.model.Post
import com.example.ui.screens.DetailsScreen
import com.example.ui.screens.FavoritesScreen
import com.example.ui.screens.PostsScreen
import com.example.ui.theme.MyApplicationTheme
import com.example.ui.viewmodel.PostViewModel

class MainActivity : ComponentActivity() {

    private val viewModel: PostViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MyApplicationTheme {
                PostReaderApp(viewModel = viewModel)
            }
        }
    }
}

@Composable
fun PostReaderApp(viewModel: PostViewModel) {
    val navController = rememberNavController()
    var selectedPost by remember { mutableStateOf<Post?>(null) }

    NavHost(
        navController = navController,
        startDestination = "posts",
        modifier = Modifier.fillMaxSize()
    ) {
        composable("posts") {
            PostsScreen(
                viewModel = viewModel,
                onNavigateToDetails = { post ->
                    selectedPost = post
                    navController.navigate("details")
                },
                onNavigateToFavorites = {
                    navController.navigate("favorites")
                }
            )
        }

        composable("details") {
            selectedPost?.let { post ->
                DetailsScreen(
                    post = post,
                    viewModel = viewModel,
                    onBack = { navController.popBackStack() }
                )
            }
        }

        composable("favorites") {
            FavoritesScreen(
                viewModel = viewModel,
                onBack = { navController.popBackStack() }
            )
        }
    }
}
