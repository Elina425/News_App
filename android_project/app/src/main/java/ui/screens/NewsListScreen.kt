package ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.ExperimentalMaterialApi
import androidx.compose.material.pullrefresh.PullRefreshIndicator
import androidx.compose.material.pullrefresh.pullRefresh
import androidx.compose.material.pullrefresh.rememberPullRefreshState
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import coil.compose.rememberAsyncImagePainter
import domain.models.Article
import domain.models.ResultState
import domain.viewmodel.NewsViewModel
import androidx.compose.ui.unit.sp
import androidx.compose.ui.text.style.TextOverflow

@Composable
fun NewsApp() {
    // This is the main entry point Composable, typically called from MainActivity
    Scaffold(
        topBar = { NewsAppBar() }
    ) { paddingValues ->
        Box(modifier = Modifier.padding(paddingValues).fillMaxSize()) {
            NewsListScreen()
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NewsAppBar() {
    TopAppBar(
        title = {
            Text(
                "News",
                color = Color.White,
                fontWeight = FontWeight.Bold
            )
        },
        colors = TopAppBarDefaults.topAppBarColors(containerColor = Color(0xFF192A56)), // Dark Blue
        // Part 2 will add search and filter actions here
    )
}

@OptIn(ExperimentalMaterialApi::class)
@Composable
fun NewsListScreen(viewModel: NewsViewModel = viewModel()) {
    // Collect the state flows from the ViewModel
    val state by viewModel.newsState.collectAsState()
    val isRefreshing by viewModel.isRefreshing.collectAsState()

    // Pull-to-Refresh State (Part 1 requirement)
    // Links the ViewModel's state (isRefreshing) to the UI's onRefresh action.
    val pullRefreshState = rememberPullRefreshState(
        refreshing = isRefreshing,
        onRefresh = { viewModel.loadNews(isRefresh = true) }
    )

    // The Box and Modifier.pullRefresh wrap the entire content to enable the pull gesture
    Box(Modifier.pullRefresh(pullRefreshState).fillMaxSize()) {
        when (state) {
            is ResultState.Loading -> {
                if (!isRefreshing) {
                    // Show full screen loading indicator only on initial load
                    CircularProgressIndicator(Modifier.align(Alignment.Center))
                }
            }
            is ResultState.Success -> {
                val articles = (state as ResultState.Success).data
                LazyColumn(contentPadding = PaddingValues(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    items(articles) { article ->
                        // The onClick lambda is empty for Part 1 (no navigation yet)
                        NewsCard(article = article, onClick = { /* Part 2 Navigation */ })
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

        // Pull-to-Refresh Indicator (Part 1 requirement)
        // Must be placed outside the ListView but inside the PullRefresh Box
        PullRefreshIndicator(
            refreshing = isRefreshing,
            state = pullRefreshState,
            modifier = Modifier.align(Alignment.TopCenter)
        )
    }
}

@Composable
fun NewsCard(article: Article, onClick: () -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth().clickable { onClick() },
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Row(modifier = Modifier.padding(12.dp).heightIn(min = 100.dp)) {
            // Image
            val painter = rememberAsyncImagePainter(
                model = article.urlToImage,
                // Fallback to placeholder image if null or error
                error = rememberAsyncImagePainter("https://placehold.co/100x100/A0A0A0/ffffff?text=Image"),
                placeholder = rememberAsyncImagePainter("https://placehold.co/100x100/E0E0E0/ffffff?text=Loading"),
            )

            Image(
                painter = painter,
                contentDescription = "Article thumbnail",
                contentScale = ContentScale.Crop,
                modifier = Modifier
                    .size(100.dp)
                    .clip(RoundedCornerShape(8.dp))
                    .background(Color.LightGray)
            )

            Spacer(modifier = Modifier.width(12.dp))

            // Content
            Column(modifier = Modifier.fillMaxHeight(), verticalArrangement = Arrangement.Center) {
                Text(
                    text = article.title,
                    fontWeight = FontWeight.Bold,
                    fontSize = 16.sp, // Cleaned: using 16.sp syntax
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "${article.sourceName} | ${article.author}",
                    color = Color.Gray,
                    fontSize = 12.sp, // Cleaned: using 12.sp syntax
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                // Part 2 will add the description here
            }
        }
    }
}