package com.example.height4kid.database.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import com.example.height4kid.database.entity.StandardDataEntity

@Dao
interface StandardDataDao {
    @Insert
    suspend fun insert(data: StandardDataEntity)

    @Insert
    suspend fun insertAll(dataList: List<StandardDataEntity>)

    @Query("SELECT * FROM standard_data WHERE gender = :gender ORDER BY age")
    suspend fun getDataByGender(gender: String): List<StandardDataEntity>

    @Query("SELECT * FROM standard_data WHERE gender = :gender AND age = :age")
    suspend fun getDataByGenderAndAge(gender: String, age: Int): StandardDataEntity?

    @Query("DELETE FROM standard_data")
    suspend fun deleteAll()

    @Query("SELECT COUNT(*) FROM standard_data")
    suspend fun getCount(): Int

    @Query("SELECT * FROM standard_data")
    suspend fun getAllStandardData(): List<StandardDataEntity>
}