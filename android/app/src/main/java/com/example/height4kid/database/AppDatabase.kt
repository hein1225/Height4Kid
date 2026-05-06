package com.example.height4kid.database

import androidx.room.Database
import androidx.room.RoomDatabase
import com.example.height4kid.database.dao.*
import com.example.height4kid.database.entity.*

@Database(
    entities = [
        ChildEntity::class,
        GrowthRecordEntity::class,
        StandardDataEntity::class
    ],
    version = 1,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun childDao(): ChildDao
    abstract fun growthRecordDao(): GrowthRecordDao
    abstract fun standardDataDao(): StandardDataDao
}