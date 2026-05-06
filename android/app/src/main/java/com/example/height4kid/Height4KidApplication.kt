package com.example.height4kid

import android.app.Application
import androidx.room.Room
import com.example.height4kid.database.AppDatabase

class Height4KidApplication : Application() {
    lateinit var database: AppDatabase
        private set

    override fun onCreate() {
        super.onCreate()
        database = Room.databaseBuilder(
            applicationContext,
            AppDatabase::class.java,
            "height4kid-db"
        ).build()
    }
}