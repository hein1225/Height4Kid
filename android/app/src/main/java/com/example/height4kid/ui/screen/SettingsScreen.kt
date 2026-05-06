package com.example.height4kid.ui.screen

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.height4kid.ui.theme.PeachPink

@Composable
fun SettingsScreen(
    onBackupClick: () -> Unit,
    onRestoreClick: () -> Unit,
    backupMessage: String,
    onBack: () -> Unit
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("设置", color = Color.White) },
                backgroundColor = PeachPink,
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Text("<", color = Color.White, fontSize = 24.sp)
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp)
        ) {
            Card(
                shape = RoundedCornerShape(16.dp),
                elevation = 4.dp,
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(modifier = Modifier.fillMaxWidth()) {
                    Button(
                        onClick = onBackupClick,
                        modifier = Modifier.fillMaxWidth(),
                        contentPadding = PaddingValues(16.dp),
                        colors = ButtonDefaults.buttonColors(backgroundColor = Color.White)
                    ) {
                        Text("☁️", fontSize = 24.sp)
                        Spacer(modifier = Modifier.width(16.dp))
                        Text("数据备份", fontSize = 18.sp, color = Color.Black)
                    }
                    Divider()
                    Button(
                        onClick = onRestoreClick,
                        modifier = Modifier.fillMaxWidth(),
                        contentPadding = PaddingValues(16.dp),
                        colors = ButtonDefaults.buttonColors(backgroundColor = Color.White)
                    ) {
                        Text("📥", fontSize = 24.sp)
                        Spacer(modifier = Modifier.width(16.dp))
                        Text("数据还原", fontSize = 18.sp, color = Color.Black)
                    }
                }
            }

            if (backupMessage.isNotEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 16.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = backupMessage,
                        fontSize = 14.sp,
                        color = if (backupMessage.contains("成功")) Color.Green else Color.Red
                    )
                }
            }
        }
    }
}