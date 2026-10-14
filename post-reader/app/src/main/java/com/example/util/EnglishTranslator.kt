package com.example.util

import com.example.data.model.Post

object EnglishTranslator {

    private val englishTitles = listOf(
        "Building Modern Mobile Applications with Clean Architecture",
        "Mastering REST APIs and Asynchronous Network Requests",
        "Local Database Persistence and Offline-First Strategies",
        "Declarative UI Design and State Management Best Practices",
        "Ensuring High App Performance and Battery Efficiency",
        "Understanding User Authentication and Zero-Trust Security",
        "Writing Robust Unit Tests and Automated Integration Suites",
        "Designing Accessible and Inclusive Interfaces for Everyone",
        "Reactive Streams and Asynchronous Coroutines in Kotlin",
        "Version Control Workflows and Continuous Delivery Pipelines",
        "Optimizing Memory Usage and Avoiding Mobile Leaks",
        "Architecting Scalable Microservices and Cloud APIs",
        "Cross-Platform vs Native: Choosing the Right Mobile Stack",
        "Handling Runtime Permissions Gracefully on Modern Devices",
        "Design Tokens, Dynamic Color, and Material Design 3 Guidelines",
        "Debugging Network Failures and Implementing Retry Policies",
        "Key-Value Stores vs Relational SQLite Databases",
        "Background Task Scheduling and Push Notification Systems",
        "Clean Code Principles for Maintainable Software Systems",
        "Edge Computing and On-Device Machine Learning Models"
    )

    private val englishBodies = listOf(
        "Modern mobile development emphasizes modular architecture, declarative user interfaces, and unidirectional data flow. Structuring code into independent layers improves testability, readability, and team collaboration across projects.",
        "Consuming RESTful web services requires handling various HTTP status codes, such as 200 OK for successful retrieval and 201 Created for new resource creation. Proper error handling guarantees smooth user experiences during network disruptions.",
        "Local storage guarantees that user-authored content, saved bookmarks, and custom notes remain accessible even when an internet connection is unavailable. Database transactions protect against data corruption during unexpected shutdowns.",
        "State management decouples presentation components from underlying business logic. Keeping state immutable and emitting updates through reactive flows ensures UI elements recompose efficiently without stutter.",
        "Optimizing application speed involves minimizing layout overdraw, offloading expensive calculations from the main thread, and caching static assets. These practices save battery life and maintain fluid 60fps animations.",
        "Securing user data demands token-based authentication, encrypted local storage, and secure HTTPS transport layers. Sensitive keys and secrets should never be embedded directly into source code repositories.",
        "Automated testing provides confidence during refactoring. Combining local JVM unit tests with integration verification allows engineering teams to detect regressions before shipping updates to production.",
        "Accessibility features such as screen reader labels, high-contrast themes, and adequate touch targets ensure mobile applications can be operated comfortably by users of all abilities.",
        "Asynchronous programming allows applications to execute long-running tasks, such as file downloads or database queries, without freezing the user interface. Coroutines make concurrent code read sequentially and simply.",
        "Effective software engineering relies on continuous integration workflows. Automated linter checks, build validation, and automated releases streamline the development cycle and preserve high code standards."
    )

    /**
     * Converts a JSONPlaceholder post (which is in Latin/Lorem Ipsum) into clear,
     * readable English text based on its post ID, while preserving newly created
     * posts that already contain custom English text.
     */
    fun toEnglish(post: Post): Post {
        // If post was created by user (usually id > 100 or contains typical English words), keep user input
        if (post.id > 100) {
            return post
        }

        // Deterministic English mapping based on the post ID (1 to 100)
        val index = (post.id - 1).coerceAtLeast(0)
        val title = englishTitles[index % englishTitles.size] + " #${post.id}"
        val body = englishBodies[index % englishBodies.size] + " " +
                englishBodies[(index + 3) % englishBodies.size]

        return post.copy(
            title = title,
            body = body
        )
    }

    fun isLatin(text: String): Boolean {
        val latinWords = setOf("quia", "sunt", "aut", "facere", "dolor", "consectetur", "reprehenderit", "ipsam", "tempore", "voluptate", "nihil")
        val words = text.lowercase().split("\\s+".toRegex())
        return words.count { it in latinWords } >= 2
    }
}
