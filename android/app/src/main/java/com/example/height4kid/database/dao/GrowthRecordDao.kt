package com.example.height4kid.database.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Update
import com.example.height4kid.database.entity.GrowthRecordEntity

@Dao
interface GrowthRecordDao {
    @Insert
    suspend fun insert(record: GrowthRecordEntity)

    @Update
    suspend fun update(record: GrowthRecordEntity)

    @Query("SELECT * FROM growth_records WHERE childId = :childId ORDER BY recordDate DESC")
    suspend fun getRecordsByChildId(childId: Long): List<GrowthRecordEntity>

    @Query("SELECT * FROM growth_records WHERE id = :id")
    suspend fun getRecordById(id: Long): GrowthRecordEntity?

    @Query("DELETE FROM growth_records WHERE id = :id")
    suspend fun delete(id: Long)

    @Query("DELETE FROM growth_records WHERE childId = :childId")
    suspend fun deleteByChildId(childId: Long)

    @Query("SELECT * FROM growth_records")
    suspend fun getAllRecords(): List<GrowthRecordEntity>

    @Query("DELETE FROM growth_records")
    suspend fun deleteAll()
}