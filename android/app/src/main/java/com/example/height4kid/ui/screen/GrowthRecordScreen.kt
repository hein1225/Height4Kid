package com.example.height4kid.ui.screen

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.height4kid.database.entity.GrowthRecordEntity
import com.example.height4kid.ui.theme.PeachPink
import kotlinx.coroutines.launch

@Composable
fun GrowthRecordScreen(
    childName: String,
    records: List<GrowthRecordEntity>,
    onAddRecord: suspend (Double, Double, String) -> Unit,
    onBack: () -> Unit
) {
    var showAddDialog by remember { mutableStateOf(false) }
    var height by remember { mutableStateOf("") }
    var weight by remember { mutableStateOf("") }
    var recordDate by remember { mutableStateOf("") }
    val coroutineScope = rememberCoroutineScope()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("$childName 的成长记录", color = Color.White) },
                backgroundColor = PeachPink,
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Text("<", color = Color.White, fontSize = 24.sp)
                    }
                }
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = { showAddDialog = true },
                backgroundColor = PeachPink
            ) {
                Text("➕", color = Color.White, fontSize = 24.sp)
            }
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp)
        ) {
            if (records.isEmpty()) {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Text("暂无成长记录", fontSize = 18.sp, color = Color.Gray)
                }
            } else {
                records.forEach { record ->
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
                            Text(record.recordDate, fontSize = 16.sp, fontWeight = androidx.compose.ui.text.font.FontWeight.Bold)
                            Row(
                                modifier = Modifier.fillMaxWidth().padding(top = 8.dp),
                                horizontalArrangement = Arrangement.SpaceAround
                            ) {
                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    Text("身高", fontSize = 14.sp, color = Color.Gray)
                                    Text("${record.height} cm", fontSize = 20.sp, fontWeight = androidx.compose.ui.text.font.FontWeight.Bold)
                                }
                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    Text("体重", fontSize = 14.sp, color = Color.Gray)
                                    Text("${record.weight} kg", fontSize = 20.sp, fontWeight = androidx.compose.ui.text.font.FontWeight.Bold)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    if (showAddDialog) {
        AlertDialog(
            onDismissRequest = { showAddDialog = false },
            title = { Text("添加成长记录") },
            text = {
                Column {
                    TextField(
                        value = height,
                        onValueChange = { height = it },
                        label = { Text("身高(cm)") },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        modifier = Modifier.fillMaxWidth()
                    )
                    TextField(
                        value = weight,
                        onValueChange = { weight = it },
                        label = { Text("体重(kg)") },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        modifier = Modifier.fillMaxWidth()
                    )
                    TextField(
                        value = recordDate,
                        onValueChange = { recordDate = it },
                        label = { Text("记录日期(yyyy-MM-dd)") },
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            },
            confirmButton = {
                Button(
                    onClick = {
                        coroutineScope.launch {
                            val heightValue = height.toDoubleOrNull()
                            val weightValue = weight.toDoubleOrNull()
                            if (heightValue != null && weightValue != null && recordDate.isNotEmpty()) {
                                onAddRecord(heightValue, weightValue, recordDate)
                                showAddDialog = false
                                height = ""
                                weight = ""
                                recordDate = ""
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