package com.example.height4kid.database.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "children")
data class ChildEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val name: String,
    val gender: String,
    val birthday: String,
    val createdAt: String = "",
    val updatedAt: String = ""
)