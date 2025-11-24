package com.example.android_project.ui.screens

import androidx.compose.foundation.Image

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.ExperimentalMaterialApi
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.pullrefresh.PullRefreshIndicator
import androidx.compose.material.pullrefresh.pullRefresh
import androidx.compose.material.pullrefresh.rememberPullRefreshState
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.FilterList
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import coil.compose.rememberAsyncImagePainter
import domain.models.Article
import domain.models.ResultState
import domain.viewmodel.NewsViewModel
import androidx.compose.runtime.collectAsState
import androidx.compose.material3.Text
import androidx.lifecycle.compose.collectAsStateWithLifecycle

// PART 2: Navigation State (Handles transition between Home and Details)
sealed class Screen {
    object Home : Screen()
    data class Details(val article: Article) : Screen()
}


@Composable
fun NewsApp(viewModel: NewsViewModel = viewModel()) {
    // PART 2: Manages navigation between Home and Details
    val currentScreen = remember { mutableStateOf<Screen>(Screen.Home) }

    when (val screen = currentScreen.value) {
        is Screen.Home -> NewsListScreen(
            viewModel = viewModel,
            onArticleClick = { article -> currentScreen.value = Screen.Details(article) }
        )
        is Screen.Details -> DetailsScreen(
            article = screen.article,
            onBack = { currentScreen.value = Screen.Home }
        )
    }
}


@OptIn(ExperimentalMaterialApi::class)
@Composable
fun NewsListScreen(viewModel: NewsViewModel, onArticleClick: (Article) -> Unit) {
    val state by viewModel.newsState.collectAsState()
    val isRefreshing by viewModel.isRefreshing.collectAsState()
    val errorMessage by viewModel.errorMessage
    val searchQuery by viewModel.searchQuery

    val openFilterDialog = remember { mutableStateOf(false) }

    Scaffold(
        // PART 2: Search Bar and Filter in TopBar
        topBar = { NewsAppBar(viewModel = viewModel, onFilterClick = { openFilterDialog.value = true }) }
    ) { paddingValues ->
        // PART 1: Pull-to-Refresh State
        val pullRefreshState = rememberPullRefreshState(
            refreshing = isRefreshing,
            onRefresh = { viewModel.loadNews(isRefresh = true) }
        )

        Box(Modifier.padding(paddingValues).pullRefresh(pullRefreshState).fillMaxSize()) {

            // Handle loading and empty states
            when (state) {
                is ResultState.Loading -> {
                    if (!isRefreshing) {
                        CircularProgressIndicator(Modifier.align(Alignment.Center))
                    }
                }
                is ResultState.Success -> {
                    val articles = (state as ResultState.Success).data
                    if (articles.isEmpty()) {
                        // PART 2: "No Results Found" Message
                        Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Text("No Results Found", style = MaterialTheme.typography.titleMedium)
                                if (searchQuery.isNotEmpty()) {
                                    Text("Your search for \"$searchQuery\" did not match any articles.")
                                }
                            }
                        }
                    } else {
                        LazyColumn(contentPadding = PaddingValues(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                            items(articles) { article ->
                                NewsCard(article = article, onClick = { onArticleClick(article) })
                            }
                        }
                    }
                }
                is ResultState.Error -> {
                    Column(Modifier.fillMaxSize().padding(16.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
                        Text("Error: ${(state as ResultState.Error).message}", color = Color.Red, style = MaterialTheme.typography.bodyLarge)
                        Spacer(Modifier.height(16.dp))
                        Button(onClick = { viewModel.loadNews() }) {
                            Text("Retry")
                        }
                    }
                }
            }

            // PART 1: Pull-to-Refresh Indicator
            PullRefreshIndicator(
                refreshing = isRefreshing,
                state = pullRefreshState,
                modifier = Modifier.align(Alignment.TopCenter)
            )

            // PART 2: Error Message Snackbar
            errorMessage?.let {
                Snackbar(
                    modifier = Modifier.align(Alignment.BottomCenter).padding(16.dp),
                    containerColor = Color.Red.copy(alpha = 0.8f)
                ) {
                    Text(it, color = Color.White)
                }
            }
        }
    }

    // PART 2: Filter Modal
    if (openFilterDialog.value) {
        FilterModal(
            currentCategory = viewModel.selectedCategory.value,
            onDismiss = { openFilterDialog.value = false },
            onApply = { category ->
                viewModel.applyCategoryFilter(category)
                openFilterDialog.value = false
            }
        )
    }
}

// PART 2: Search and Filter Bar
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NewsAppBar(viewModel: NewsViewModel, onFilterClick: () -> Unit) {
    val searchQuery by viewModel.searchQuery

    TopAppBar(
        title = {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // PART 2: Search Input
                OutlinedTextField(
                    value = searchQuery,
                    onValueChange = { viewModel.onSearchQueryChange(it) },
                    placeholder = { Text("Search", color = Color.White.copy(alpha = 0.7f)) },
                    leadingIcon = { Icon(Icons.Default.Search, contentDescription = "Search", tint = Color.White) },
                    // PART 2: Clear Search Button (Remove Input)
                    trailingIcon = {
                        if (searchQuery.isNotEmpty()) {
                            IconButton(onClick = { viewModel.clearSearch() }) {
                                Icon(Icons.Default.Close, contentDescription = "Clear", tint = Color.White)
                            }
                        }
                    },
                    modifier = Modifier.weight(1f).height(48.dp),
                    singleLine = true,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedContainerColor = Color.White.copy(alpha = 0.2f),
                        unfocusedContainerColor = Color.White.copy(alpha = 0.1f),
                        focusedBorderColor = Color.White,
                        unfocusedBorderColor = Color.Transparent,
                        cursorColor = Color.White,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White
                    ),
                    shape = RoundedCornerShape(8.dp)
                )

                // PART 2: Remote Search Button (on tap)
                IconButton(
                    onClick = { viewModel.remoteSearch() },
                    enabled = !viewModel.isRefreshing.collectAsState().value
                ) {
                    Icon(Icons.Default.Search, contentDescription = "Remote Search", tint = Color.White)
                }

                // PART 2: Filter Button
                IconButton(onClick = onFilterClick) {
                    Icon(Icons.Default.FilterList, contentDescription = "Filter", tint = Color.White)
                }
            }
        },
        colors = TopAppBarDefaults.topAppBarColors(containerColor = Color(0xFF192A56)),
        navigationIcon = { /* Optional back button here if needed */ }
    )
}

// PART 2: Details Screen
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DetailsScreen(article: Article, onBack: () -> Unit) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(article.sourceName, color = Color.White) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Filled.ArrowBack, contentDescription = "Back", tint = Color.White)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color(0xFF192A56))
            )
        }
    ) { paddingValues ->
        Column(modifier = Modifier.padding(paddingValues).padding(16.dp).verticalScroll(rememberScrollState())) {

            // PART 2: Image
            Image(
                painter = rememberAsyncImagePainter(
                    model = article.urlToImage
                        ?: "https://placehold.co/600x300/60A5FA/ffffff?text=No+Image"
                ),
                contentDescription = "Article Image",
                contentScale = ContentScale.Crop,
                modifier = Modifier.fillMaxWidth().height(200.dp).clip(RoundedCornerShape(12.dp))
            )

            Spacer(modifier = Modifier.height(16.dp))

            // PART 2: Title
            Text(article.title, style = MaterialTheme.typography.headlineMedium.copy(fontWeight = FontWeight.Bold))

            Spacer(modifier = Modifier.height(12.dp))

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                // PART 2: Author and Source
                Text("Author: ${article.author}", style = MaterialTheme.typography.bodyMedium.copy(fontStyle = FontStyle.Italic, color = Color.Gray))
                Text("Source: ${article.sourceName}", style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.SemiBold, color = Color(0xFF3B82F6)))
            }

            Divider(modifier = Modifier.padding(vertical = 16.dp))

            // PART 2: Description
            Text("Description:", style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold))
            Spacer(modifier = Modifier.height(8.dp))
            Text(article.description, style = MaterialTheme.typography.bodyLarge)

            Spacer(modifier = Modifier.height(16.dp))

            // PART 2: Content Snippet
            Text("Content Snippet:", style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold))
            Spacer(modifier = Modifier.height(8.dp))
            Text(article.content, style = MaterialTheme.typography.bodyLarge.copy(color = Color.DarkGray))
        }
    }
}

// PART 2: Filter Modal
@Composable
fun FilterModal(currentCategory: String, onDismiss: () -> Unit, onApply: (String) -> Unit, viewModel: NewsViewModel = viewModel()) {
    val categories = viewModel.categories
    val tempCategory = remember { mutableStateOf(currentCategory) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Select Category", fontWeight = FontWeight.Bold) },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                categories.forEach { category ->
                    val isSelected = category.equals(tempCategory.value, ignoreCase = true)
                    Button(
                        onClick = {
                            tempCategory.value = if (isSelected) "" else category
                        },
                        colors = ButtonDefaults.buttonColors(
                            containerColor = if (isSelected) Color(0xFF192A56) else Color.LightGray,
                            contentColor = if (isSelected) Color.White else Color.Black
                        ),
                        modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(8.dp))
                    ) {
                        Text(category)
                    }
                }
            }
        },
        confirmButton = {
            Button(
                onClick = { onApply(tempCategory.value) },
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF3B82F6))
            ) {
                Text("Apply", color = Color.White)
            }
        },
        dismissButton = {
            Button(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}

// PART 2: Updated NewsCard to support navigation and category display
@Composable
fun NewsCard(article: Article, onClick: (Article) -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth().clickable { onClick(article) },
        shape = RoundedCornerShape(12.dp),
        elevation = CardDefaults.cardElevation(4.dp)
    ) {
        Row(modifier = Modifier.padding(12.dp)) {
            // Article Image
            Image(
                painter = rememberAsyncImagePainter(
                    model = article.urlToImage
                        ?: "https://placehold.co/100x100/60A5FA/ffffff?text=No+Image"
                ),
                contentDescription = "Article thumbnail",
                contentScale = ContentScale.Crop,
                modifier = Modifier.size(100.dp).clip(RoundedCornerShape(8.dp))
            )

            Spacer(modifier = Modifier.width(12.dp))

            // Article Info
            Column(modifier = Modifier.fillMaxHeight(), verticalArrangement = Arrangement.Center) {
                Text(
                    text = article.title,
                    fontWeight = FontWeight.Bold,
                    fontSize = 16.sp, // Using corrected sp syntax
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "${article.sourceName} | ${article.author}",
                    color = Color.Gray,
                    fontSize = 12.sp
                )
                Spacer(modifier = Modifier.height(8.dp))
                // PART 2: Display Category
                Text(
                    text = article.category.uppercase(),
                    color = Color(0xFF3B82F6),
                    fontSize = 12.sp,
                    fontWeight = FontWeight.SemiBold
                )
            }
        }
    }
}

// Simple AppTheme placeholder (assuming default colors/typography exist in ui.theme)
@Composable
fun AppTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = lightColorScheme(
            primary = Color(0xFF192A56),
            secondary = Color(0xFF3B82F6)
        ),
        content = content
    )
}