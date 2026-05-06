package com.example.height4kid.repository

import com.example.height4kid.database.AppDatabase
import com.example.height4kid.database.entity.GrowthRecordEntity
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

class GrowthRecordRepository(private val db: AppDatabase) {
    private val growthRecordDao = db.growthRecordDao()
    private val formatter = DateTimeFormatter.ISO_LOCAL_DATE_TIME

    suspend fun createRecord(childId: Long, height: Double, weight: Double, recordDate: String): GrowthRecordEntity {
        val now = LocalDateTime.now().format(formatter)
        val record = GrowthRecordEntity(
            childId = childId,
            height = height,
            weight = weight,
            recordDate = recordDate,
            createdAt = now,
            updatedAt = now
        )
        growthRecordDao.insert(record)
        return record
    }

    suspend fun getRecordsByChildId(childId: Long): List<GrowthRecordEntity> {
        return growthRecordDao.getRecordsByChildId(childId)
    }

    suspend fun getRecordById(id: Long): GrowthRecordEntity? {
        return growthRecordDao.getRecordById(id)
    }

    suspend fun updateRecord(id: Long, height: Double, weight: Double, recordDate: String) {
        val record = growthRecordDao.getRecordById(id)
        record?.let {
            val updatedRecord = it.copy(
                height = height,
                weight = weight,
                recordDate = recordDate,
                updatedAt = LocalDateTime.now().format(formatter)
            )
            growthRecordDao.update(updatedRecord)
        }
    }

    suspend fun deleteRecord(id: Long) {
        growthRecordDao.delete(id)
    }
}