package com.example.height4kid.database.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Update
import com.example.height4kid.database.entity.ChildEntity

@Dao
interface ChildDao {
    @Insert
    suspend fun insert(child: ChildEntity)

    @Update
    suspend fun update(child: ChildEntity)

    @Query("SELECT * FROM children WHERE id = :id")
    suspend fun getChildById(id: Long): ChildEntity?

    @Query("DELETE FROM children WHERE id = :id")
    suspend fun delete(id: Long)

    @Query("SELECT * FROM children")
    suspend fun getAllChildren(): List<ChildEntity>

    @Query("DELETE FROM children")
    suspend fun deleteAll()
}