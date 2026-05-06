package com.example.height4kid.ui.screen

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Edit
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.height4kid.database.entity.ChildEntity
import com.example.height4kid.ui.theme.PeachPink
import kotlinx.coroutines.launch
import kotlin.collections.List

@Composable
fun ChildManageScreen(
    children: List<ChildEntity>,
    onCreateChild: suspend (String, String, String) -> Unit,
    onBack: () -> Unit
) {
    var showAddDialog by remember { mutableStateOf(false) }
    var name by remember { mutableStateOf("") }
    var gender by remember { mutableStateOf("男") }
    var birthday by remember { mutableStateOf("") }
    val coroutineScope = rememberCoroutineScope()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("儿童管理", color = Color.White) },
                backgroundColor = PeachPink,
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(
                            imageVector = Icons.Default.ArrowBack,
                            contentDescription = "返回",
                            tint = Color.White
                        )
                    }
                }
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = {
                    name = ""
                    gender = "男"
                    birthday = ""
                    showAddDialog = true
                },
                backgroundColor = PeachPink
            ) {
                Icon(Icons.Default.Edit, contentDescription = "添加儿童", tint = Color.White)
            }
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp)
        ) {
            if (children.isEmpty()) {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Text("暂无儿童信息", fontSize = 18.sp, color = Color.Gray)
                }
            } else {
                children.forEach { child ->
                    Card(
                        shape = RoundedCornerShape(16.dp),
                        elevation = 4.dp,
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(bottom = 12.dp)
                    ) {
                        Column(
                            modifier = Modifier.fillMaxWidth().padding(16.dp)
                        ) {
                            Text(child.name, fontSize = 20.sp, fontWeight = FontWeight.Bold)
                            Text("${child.gender} · ${child.birthday}", fontSize = 14.sp, color = Color.Gray)
                        }
                    }
                }
            }
        }
    }

    if (showAddDialog) {
        AlertDialog(
            onDismissRequest = { showAddDialog = false },
            title = { Text("添加儿童") },
            text = {
                Column {
                    TextField(
                        value = name,
                        onValueChange = { name = it },
                        label = { Text("姓名") },
                        modifier = Modifier.fillMaxWidth()
                    )
                    Row {
                        Text("性别:", modifier = Modifier.padding(end = 8.dp))
                        Row {
                            RadioButton(
                                selected = gender == "男",
                                onClick = { gender = "男" }
                            )
                            Text("男")
                            RadioButton(
                                selected = gender == "女",
                                onClick = { gender = "女" }
                            )
                            Text("女")
                        }
                    }
                    TextField(
                        value = birthday,
                        onValueChange = { birthday = it },
                        label = { Text("出生日期(yyyy-MM-dd)") },
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            },
            confirmButton = {
                Button(
                    onClick = {
                        coroutineScope.launch {
                            if (name.isNotEmpty() && birthday.isNotEmpty()) {
                                onCreateChild(name, gender, birthday)
                                showAddDialog = false
                                name = ""
                                birthday = ""
                            }
                        }
                    },
                    colors = ButtonDefaults.buttonColors(backgroundColor = PeachPink)
                ) {
                    Text("确认添加", color = Color.White)
                }
            },
            dismissButton = {
                Button(
                    onClick = { showAddDialog = false },
                    colors = ButtonDefaults.buttonColors(backgroundColor = Color.Gray)
                ) {
                    Text("取消", color = Color.White)
                }
            }
        )
    }
}