package com.example.height4kid.ui.screen

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.height4kid.database.entity.ChildEntity
import com.example.height4kid.ui.theme.PeachPink
import com.example.height4kid.ui.theme.WarmApricot
import kotlin.collections.List

@Composable
fun HomeScreen(
    children: List<ChildEntity>,
    selectedChildId: Long?,
    onSelectChild: (Long) -> Unit,
    onAddChild: () -> Unit,
    onViewSettings: () -> Unit,
    onViewGrowthRecord: (Long) -> Unit
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("身高成长小助手", color = Color.White) },
                backgroundColor = PeachPink,
                actions = {
                    IconButton(onClick = onViewSettings) {
                        Text("⚙️", fontSize = 24.sp)
                    }
                }
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = onAddChild,
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
            if (children.isEmpty()) {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text("👶", fontSize = 64.sp)
                        Text("暂无儿童信息", fontSize = 18.sp, color = Color.Gray, modifier = Modifier.padding(top = 16.dp))
                        Text("点击右下角添加", fontSize = 14.sp, color = Color.LightGray)
                    }
                }
            } else {
                children.forEach { child ->
                    Card(
                        shape = RoundedCornerShape(16.dp),
                        elevation = 4.dp,
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(bottom = 12.dp),
                        backgroundColor = if (selectedChildId == child.id) WarmApricot else Color.White
                    ) {
                        Column(
                            modifier = Modifier.fillMaxWidth().padding(16.dp)
                        ) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Column {
                                    Text(child.name, fontSize = 20.sp, fontWeight = FontWeight.Bold)
                                    Text("${child.gender} · ${child.birthday}", fontSize = 14.sp, color = Color.Gray)
                                }
                                RadioButton(
                                    selected = selectedChildId == child.id,
                                    onClick = { onSelectChild(child.id) }
                                )
                            }

                            Button(
                                onClick = { onViewGrowthRecord(child.id) },
                                modifier = Modifier.fillMaxWidth().padding(top = 12.dp),
                                shape = RoundedCornerShape(8.dp),
                                colors = ButtonDefaults.buttonColors(backgroundColor = PeachPink)
                            ) {
                                Text("查看成长记录", color = Color.White)
                            }
                        }
                    }
                }
            }
        }
    }
}