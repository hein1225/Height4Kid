package com.example.height4kid.database.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "standard_data")
data class StandardDataEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val gender: String,
    val age: Int,
    val heightP3: Double,
    val heightP10: Double,
    val heightP25: Double,
    val heightP50: Double,
    val heightP75: Double,
    val heightP90: Double,
    val heightP97: Double,
    val weightP3: Double,
    val weightP10: Double,
    val weightP25: Double,
    val weightP50: Double,
    val weightP75: Double,
    val weightP90: Double,
    val weightP97: Double
)