package com.example.height4kid

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Surface
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.height4kid.database.entity.ChildEntity
import com.example.height4kid.database.entity.GrowthRecordEntity
import com.example.height4kid.repository.BackupRepository
import com.example.height4kid.repository.ChildRepository
import com.example.height4kid.repository.GrowthRecordRepository
import com.example.height4kid.repository.StandardDataRepository
import com.example.height4kid.ui.screen.*
import com.example.height4kid.ui.theme.Height4KidTheme
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainViewModel(
    private val childRepository: ChildRepository,
    private val growthRecordRepository: GrowthRecordRepository,
    private val backupRepository: BackupRepository,
    private val standardDataRepository: StandardDataRepository
) : ViewModel() {
    val currentScreen = mutableStateOf<Screen>(Screen.Home)
    val children = mutableStateListOf<ChildEntity>()
    val records = mutableStateListOf<GrowthRecordEntity>()
    val selectedChildId = mutableStateOf<Long?>(null)
    val selectedChildName = mutableStateOf("")
    val backupMessage = mutableStateOf("")

    fun loadChildren() {
        viewModelScope.launch(Dispatchers.IO) {
            standardDataRepository.initStandardDataIfEmpty()
            val result = childRepository.getAllChildren()
            withContext(Dispatchers.Main) {
                children.clear()
                children.addAll(result)
                if (result.isNotEmpty() && selectedChildId.value == null) {
                    selectedChildId.value = result.first().id
                }
            }
        }
    }

    fun loadRecords(childId: Long) {
        viewModelScope.launch(Dispatchers.IO) {
            val result = growthRecordRepository.getRecordsByChildId(childId)
            withContext(Dispatchers.Main) {
                records.clear()
                records.addAll(result)
            }
        }
    }

    fun addChild(name: String, gender: String, birthday: String) {
        viewModelScope.launch(Dispatchers.IO) {
            childRepository.createChild(name, gender, birthday)
            withContext(Dispatchers.Main) {
                loadChildren()
            }
        }
    }

    fun getChildName(childId: Long): String {
        return children.find { it.id == childId }?.name ?: ""
    }

    fun addRecord(childId: Long, height: Double, weight: Double, recordDate: String) {
        viewModelScope.launch(Dispatchers.IO) {
            growthRecordRepository.createRecord(childId, height, weight, recordDate)
            withContext(Dispatchers.Main) {
                loadRecords(childId)
            }
        }
    }

    fun backupData() {
        viewModelScope.launch(Dispatchers.IO) {
            val path = backupRepository.createBackup()
            withContext(Dispatchers.Main) {
                backupMessage.value = if (path != null) "备份成功" else "备份失败"
            }
        }
    }

    fun restoreData() {
        viewModelScope.launch(Dispatchers.IO) {
            val backups = backupRepository.getBackupFiles()
            if (backups.isNotEmpty()) {
                val success = backupRepository.restoreBackup(backups.last().absolutePath)
                withContext(Dispatchers.Main) {
                    backupMessage.value = if (success) "还原成功" else "还原失败"
                    if (success) {
                        loadChildren()
                    }
                }
            } else {
                backupMessage.value = "没有备份文件"
            }
        }
    }

    enum class Screen {
        Home,
        ChildManage,
        GrowthRecord,
        Settings
    }
}

class MainActivity : ComponentActivity() {
    private lateinit var childRepository: ChildRepository
    private lateinit var growthRecordRepository: GrowthRecordRepository
    private lateinit var backupRepository: BackupRepository
    private lateinit var standardDataRepository: StandardDataRepository

    private val app get() = application as Height4KidApplication

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        childRepository = ChildRepository(app.database)
        growthRecordRepository = GrowthRecordRepository(app.database)
        backupRepository = BackupRepository(app.database, this)
        standardDataRepository = StandardDataRepository(app.database)

        setContent {
            Height4KidTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colors.background
                ) {
                    val viewModel = viewModel<MainViewModel>(
                        factory = object : ViewModelProvider.Factory {
                            @Suppress("UNCHECKED_CAST")
                            override fun <T : ViewModel> create(modelClass: Class<T>): T {
                                return MainViewModel(
                                    childRepository,
                                    growthRecordRepository,
                                    backupRepository,
                                    standardDataRepository
                                ) as T
                            }
                        }
                    )

                    LaunchedEffect(Unit) {
                        viewModel.loadChildren()
                    }

                    when (viewModel.currentScreen.value) {
                        MainViewModel.Screen.Home -> {
                            HomeScreen(
                                children = viewModel.children,
                                selectedChildId = viewModel.selectedChildId.value,
                                onSelectChild = { viewModel.selectedChildId.value = it },
                                onAddChild = { viewModel.currentScreen.value = MainViewModel.Screen.ChildManage },
                                onViewSettings = { viewModel.currentScreen.value = MainViewModel.Screen.Settings },
                                onViewGrowthRecord = { childId ->
                                    viewModel.loadRecords(childId)
                                    viewModel.selectedChildName.value = viewModel.getChildName(childId)
                                    viewModel.currentScreen.value = MainViewModel.Screen.GrowthRecord
                                }
                            )
                        }
                        MainViewModel.Screen.ChildManage -> {
                            ChildManageScreen(
                                children = viewModel.children,
                                onCreateChild = { name, gender, birthday ->
                                    viewModel.addChild(name, gender, birthday)
                                    viewModel.currentScreen.value = MainViewModel.Screen.Home
                                },
                                onBack = { viewModel.currentScreen.value = MainViewModel.Screen.Home }
                            )
                        }
                        MainViewModel.Screen.GrowthRecord -> {
                            GrowthRecordScreen(
                                childName = viewModel.selectedChildName.value,
                                records = viewModel.records,
                                onAddRecord = { height, weight, recordDate ->
                                    viewModel.selectedChildId.value?.let { childId ->
                                        viewModel.addRecord(childId, height, weight, recordDate)
                                    }
                                },
                                onBack = { viewModel.currentScreen.value = MainViewModel.Screen.Home }
                            )
                        }
                        MainViewModel.Screen.Settings -> {
                            SettingsScreen(
                                onBackupClick = { viewModel.backupData() },
                                onRestoreClick = { viewModel.restoreData() },
                                backupMessage = viewModel.backupMessage.value,
                                onBack = { viewModel.currentScreen.value = MainViewModel.Screen.Home }
                            )
                        }
                    }
                }
            }
        }
    }
}