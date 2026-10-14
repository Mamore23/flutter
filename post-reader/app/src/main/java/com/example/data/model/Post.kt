package com.example.data.model

import com.squareup.moshi.Json
import com.squareup.moshi.JsonClass

@JsonClass(generateAdapter = true)
data class Post(
    @Json(name = "id") val id: Int = 0,
    @Json(name = "userId") val userId: Int = 1,
    @Json(name = "title") val title: String,
    @Json(name = "body") val body: String
)

@JsonClass(generateAdapter = true)
data class CreatePostRequest(
    @Json(name = "title") val title: String,
    @Json(name = "body") val body: String,
    @Json(name = "userId") val userId: Int = 1
)
