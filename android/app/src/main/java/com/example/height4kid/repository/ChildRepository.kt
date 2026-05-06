package com.example.height4kid.repository

import com.example.height4kid.database.AppDatabase
import com.example.height4kid.database.entity.ChildEntity
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

class ChildRepository(private val db: AppDatabase) {
    private val childDao = db.childDao()
    private val formatter = DateTimeFormatter.ISO_LOCAL_DATE_TIME

    suspend fun createChild(name: String, gender: String, birthday: String): ChildEntity {
        return withContext(Dispatchers.IO) {
            val now = LocalDateTime.now().format(formatter)
            val child = ChildEntity(
                name = name,
                gender = gender,
                birthday = birthday,
                createdAt = now,
                updatedAt = now
            )
            childDao.insert(child)
            child
        }
    }

    suspend fun getAllChildren(): List<ChildEntity> {
        return withContext(Dispatchers.IO) {
            childDao.getAllChildren()
        }
    }

    suspend fun getChildById(id: Long): ChildEntity? {
        return withContext(Dispatchers.IO) {
            childDao.getChildById(id)
        }
    }

    suspend fun updateChild(id: Long, name: String, gender: String, birthday: String) {
        withContext(Dispatchers.IO) {
            val child = childDao.getChildById(id)
            child?.let {
                val updatedChild = it.copy(
                    name = name,
                    gender = gender,
                    birthday = birthday,
                    updatedAt = LocalDateTime.now().format(formatter)
                )
                childDao.update(updatedChild)
            }
        }
    }

    suspend fun deleteChild(id: Long) {
        withContext(Dispatchers.IO) {
            childDao.delete(id)
        }
    }
}