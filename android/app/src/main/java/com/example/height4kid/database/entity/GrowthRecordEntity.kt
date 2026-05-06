package com.example.height4kid.database.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "growth_records")
data class GrowthRecordEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val childId: Long,
    val height: Double,
    val weight: Double,
    val recordDate: String,
    val serverId: Long? = null,
    val createdAt: String,
    val updatedAt: String
)