package com.example.height4kid.repository

import android.content.Context
import android.os.Environment
import com.example.height4kid.database.AppDatabase
import com.example.height4kid.database.entity.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

class BackupRepository(private val db: AppDatabase, private val context: Context) {
    private val formatter = DateTimeFormatter.ISO_LOCAL_DATE_TIME

    suspend fun createBackup(): String? {
        return withContext(Dispatchers.IO) {
            try {
                val backupDir = getBackupDirectory()
                if (!backupDir.exists()) {
                    backupDir.mkdirs()
                }

                val timestamp = LocalDateTime.now().format(formatter).replace(":", "-")
                val backupFile = File(backupDir, "height4kid_backup_$timestamp.json")

                val children = db.childDao().getAllChildren()
                val records = db.growthRecordDao().getAllRecords()
                val standardData = db.standardDataDao().getAllStandardData()

                val json = JSONObject()
                json.put("version", "1.0")
                json.put("backupTime", timestamp)

                json.put("children", convertToJsonArray(children))
                json.put("growthRecords", convertToJsonArray(records))
                json.put("standardData", convertToJsonArray(standardData))

                FileOutputStream(backupFile).use { it.write(json.toString(4).toByteArray()) }
                backupFile.absolutePath
            } catch (e: Exception) {
                e.printStackTrace()
                null
            }
        }
    }

    suspend fun restoreBackup(filePath: String): Boolean {
        return withContext(Dispatchers.IO) {
            try {
                val file = File(filePath)
                if (!file.exists()) {
                    return@withContext false
                }

                val jsonString = FileInputStream(file).bufferedReader().readText()
                val json = JSONObject(jsonString)

                db.childDao().deleteAll()
                db.growthRecordDao().deleteAll()
                db.standardDataDao().deleteAll()

                json.getJSONArray("children").let { array ->
                    for (i in 0 until array.length()) {
                        val obj = array.getJSONObject(i)
                        db.childDao().insert(ChildEntity(
                            id = obj.optLong("id"),
                            name = obj.getString("name"),
                            gender = obj.getString("gender"),
                            birthday = obj.getString("birthday"),
                            createdAt = obj.optString("createdAt"),
                            updatedAt = obj.optString("updatedAt")
                        ))
                    }
                }

                json.getJSONArray("growthRecords").let { array ->
                    for (i in 0 until array.length()) {
                        val obj = array.getJSONObject(i)
                        db.growthRecordDao().insert(GrowthRecordEntity(
                            id = obj.optLong("id"),
                            childId = obj.getLong("childId"),
                            height = obj.getDouble("height"),
                            weight = obj.getDouble("weight"),
                            recordDate = obj.getString("recordDate"),
                            createdAt = obj.optString("createdAt"),
                            updatedAt = obj.optString("updatedAt")
                        ))
                    }
                }

                json.getJSONArray("standardData").let { array ->
                    for (i in 0 until array.length()) {
                        val obj = array.getJSONObject(i)
                        db.standardDataDao().insert(StandardDataEntity(
                            id = obj.optLong("id"),
                            age = obj.getInt("age"),
                            gender = obj.getString("gender"),
                            heightP3 = obj.getDouble("heightP3"),
                            heightP10 = obj.getDouble("heightP10"),
                            heightP25 = obj.getDouble("heightP25"),
                            heightP50 = obj.getDouble("heightP50"),
                            heightP75 = obj.getDouble("heightP75"),
                            heightP90 = obj.getDouble("heightP90"),
                            heightP97 = obj.getDouble("heightP97"),
                            weightP3 = obj.getDouble("weightP3"),
                            weightP10 = obj.getDouble("weightP10"),
                            weightP25 = obj.getDouble("weightP25"),
                            weightP50 = obj.getDouble("weightP50"),
                            weightP75 = obj.getDouble("weightP75"),
                            weightP90 = obj.getDouble("weightP90"),
                            weightP97 = obj.getDouble("weightP97")
                        ))
                    }
                }
                true
            } catch (e: Exception) {
                e.printStackTrace()
                false
            }
        }
    }

    suspend fun getBackupFiles(): List<File> {
        return withContext(Dispatchers.IO) {
            val backupDir = getBackupDirectory()
            if (backupDir.exists()) {
                backupDir.listFiles { file -> file.name.endsWith(".json") }?.toList() ?: emptyList()
            } else {
                emptyList()
            }
        }
    }

    suspend fun deleteBackupFile(filePath: String): Boolean {
        return withContext(Dispatchers.IO) {
            val file = File(filePath)
            file.delete()
        }
    }

    private fun getBackupDirectory(): File {
        return File(context.getExternalFilesDir(Environment.DIRECTORY_DOCUMENTS), "backups")
    }

    private fun convertToJsonArray(list: List<*>): JSONArray {
        val array = JSONArray()
        list.forEach { item ->
            val obj = JSONObject()
            when (item) {
                is ChildEntity -> {
                    obj.put("id", item.id)
                    obj.put("name", item.name)
                    obj.put("gender", item.gender)
                    obj.put("birthday", item.birthday)
                    obj.put("createdAt", item.createdAt ?: "")
                    obj.put("updatedAt", item.updatedAt ?: "")
                }
                is GrowthRecordEntity -> {
                    obj.put("id", item.id)
                    obj.put("childId", item.childId)
                    obj.put("height", item.height)
                    obj.put("weight", item.weight)
                    obj.put("recordDate", item.recordDate)
                    obj.put("createdAt", item.createdAt ?: "")
                    obj.put("updatedAt", item.updatedAt ?: "")
                }
                is StandardDataEntity -> {
                    obj.put("id", item.id)
                    obj.put("age", item.age)
                    obj.put("gender", item.gender)
                    obj.put("heightP3", item.heightP3)
                    obj.put("heightP10", item.heightP10)
                    obj.put("heightP25", item.heightP25)
                    obj.put("heightP50", item.heightP50)
                    obj.put("heightP75", item.heightP75)
                    obj.put("heightP90", item.heightP90)
                    obj.put("heightP97", item.heightP97)
                    obj.put("weightP3", item.weightP3)
                    obj.put("weightP10", item.weightP10)
                    obj.put("weightP25", item.weightP25)
                    obj.put("weightP50", item.weightP50)
                    obj.put("weightP75", item.weightP75)
                    obj.put("weightP90", item.weightP90)
                    obj.put("weightP97", item.weightP97)
                }
            }
            array.put(obj)
        }
        return array
    }
}