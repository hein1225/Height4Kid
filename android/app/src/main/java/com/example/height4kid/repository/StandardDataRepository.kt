package com.example.height4kid.repository

import com.example.height4kid.database.AppDatabase
import com.example.height4kid.database.entity.StandardDataEntity
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class StandardDataRepository(private val db: AppDatabase) {
    private val standardDataDao = db.standardDataDao()

    suspend fun initStandardDataIfEmpty() {
        withContext(Dispatchers.IO) {
            if (standardDataDao.getCount() == 0) {
                insertDefaultStandardData()
            }
        }
    }

    private suspend fun insertDefaultStandardData() {
        val maleData = listOf(
            StandardDataEntity(gender = "MALE", age = 0, heightP3 = 45.9, heightP10 = 47.7, heightP25 = 49.0, heightP50 = 50.5, heightP75 = 52.0, heightP90 = 53.3, heightP97 = 54.7, weightP3 = 2.4, weightP10 = 2.8, weightP25 = 3.1, weightP50 = 3.3, weightP75 = 3.6, weightP90 = 4.0, weightP97 = 4.7),
            StandardDataEntity(gender = "MALE", age = 1, heightP3 = 68.6, heightP10 = 71.2, heightP25 = 73.4, heightP50 = 76.5, heightP75 = 79.6, heightP90 = 81.8, heightP97 = 84.5, weightP3 = 6.0, weightP10 = 7.0, weightP25 = 7.9, weightP50 = 9.1, weightP75 = 10.3, weightP90 = 11.0, weightP97 = 13.0),
            StandardDataEntity(gender = "MALE", age = 2, heightP3 = 77.3, heightP10 = 80.5, heightP25 = 83.0, heightP50 = 87.2, heightP75 = 91.4, heightP90 = 93.9, heightP97 = 96.8, weightP3 = 8.2, weightP10 = 9.4, weightP25 = 10.5, weightP50 = 11.9, weightP75 = 13.4, weightP90 = 14.4, weightP97 = 17.0),
            StandardDataEntity(gender = "MALE", age = 3, heightP3 = 84.4, heightP10 = 88.1, heightP25 = 90.9, heightP50 = 95.6, heightP75 = 100.3, heightP90 = 103.1, heightP97 = 106.3, weightP3 = 10.0, weightP10 = 11.5, weightP25 = 12.7, weightP50 = 14.0, weightP75 = 15.6, weightP90 = 16.9, weightP97 = 20.0),
            StandardDataEntity(gender = "MALE", age = 4, heightP3 = 90.9, heightP10 = 94.9, heightP25 = 98.1, heightP50 = 103.1, heightP75 = 108.1, heightP90 = 111.3, heightP97 = 114.8, weightP3 = 11.6, weightP10 = 13.3, weightP25 = 14.7, weightP50 = 15.7, weightP75 = 17.9, weightP90 = 19.1, weightP97 = 22.7),
            StandardDataEntity(gender = "MALE", age = 5, heightP3 = 96.8, heightP10 = 101.2, heightP25 = 104.7, heightP50 = 110.0, heightP75 = 115.3, heightP90 = 118.8, heightP97 = 122.6, weightP3 = 13.0, weightP10 = 15.0, weightP25 = 16.6, weightP50 = 17.3, weightP75 = 20.0, weightP90 = 21.1, weightP97 = 25.2),
            StandardDataEntity(gender = "MALE", age = 6, heightP3 = 102.1, heightP10 = 106.8, heightP25 = 110.6, heightP50 = 116.3, heightP75 = 122.0, heightP90 = 125.8, heightP97 = 129.9, weightP3 = 14.3, weightP10 = 16.6, weightP25 = 18.4, weightP50 = 18.9, weightP75 = 22.0, weightP90 = 23.0, weightP97 = 27.7),
            StandardDataEntity(gender = "MALE", age = 7, heightP3 = 106.9, heightP10 = 111.9, heightP25 = 116.0, heightP50 = 122.0, heightP75 = 128.0, heightP90 = 132.1, heightP97 = 136.5, weightP3 = 15.5, weightP10 = 18.1, weightP25 = 20.1, weightP50 = 20.4, weightP75 = 23.9, weightP90 = 24.9, weightP97 = 30.1),
            StandardDataEntity(gender = "MALE", age = 8, heightP3 = 111.3, heightP10 = 116.7, heightP25 = 121.1, heightP50 = 127.3, heightP75 = 133.5, heightP90 = 137.9, heightP97 = 142.6, weightP3 = 16.7, weightP10 = 19.6, weightP25 = 21.8, weightP50 = 21.9, weightP75 = 25.8, weightP90 = 26.8, weightP97 = 32.5),
            StandardDataEntity(gender = "MALE", age = 9, heightP3 = 115.4, heightP10 = 121.1, heightP25 = 125.8, heightP50 = 132.2, heightP75 = 138.6, heightP90 = 143.3, heightP97 = 148.3, weightP3 = 17.9, weightP10 = 21.1, weightP25 = 23.5, weightP50 = 23.4, weightP75 = 27.7, weightP90 = 28.7, weightP97 = 34.9),
            StandardDataEntity(gender = "MALE", age = 10, heightP3 = 119.3, heightP10 = 125.4, heightP25 = 130.4, heightP50 = 136.9, heightP75 = 143.4, heightP90 = 148.4, heightP97 = 153.7, weightP3 = 19.1, weightP10 = 22.6, weightP25 = 25.2, weightP50 = 24.9, weightP75 = 29.6, weightP90 = 30.6, weightP97 = 37.3),
            StandardDataEntity(gender = "MALE", age = 11, heightP3 = 123.0, heightP10 = 129.5, heightP25 = 134.9, heightP50 = 141.3, heightP75 = 148.2, heightP90 = 153.1, heightP97 = 158.7, weightP3 = 20.3, weightP10 = 24.1, weightP25 = 26.9, weightP50 = 26.4, weightP75 = 31.5, weightP90 = 32.5, weightP97 = 39.7),
            StandardDataEntity(gender = "MALE", age = 12, heightP3 = 126.5, heightP10 = 133.4, heightP25 = 139.1, heightP50 = 145.4, heightP75 = 152.8, heightP90 = 157.5, heightP97 = 163.4, weightP3 = 21.5, weightP10 = 25.6, weightP25 = 28.6, weightP50 = 27.9, weightP75 = 33.4, weightP90 = 34.4, weightP97 = 42.1),
            StandardDataEntity(gender = "MALE", age = 13, heightP3 = 130.0, heightP10 = 137.2, heightP25 = 143.3, heightP50 = 149.2, heightP75 = 157.4, heightP90 = 161.6, heightP97 = 167.8, weightP3 = 22.7, weightP10 = 27.1, weightP25 = 30.3, weightP50 = 29.4, weightP75 = 35.3, weightP90 = 36.3, weightP97 = 44.5),
            StandardDataEntity(gender = "MALE", age = 14, heightP3 = 133.3, heightP10 = 140.8, heightP25 = 147.3, heightP50 = 152.7, heightP75 = 161.8, heightP90 = 165.3, heightP97 = 171.9, weightP3 = 23.9, weightP10 = 28.6, weightP25 = 32.0, weightP50 = 30.9, weightP75 = 37.2, weightP90 = 38.2, weightP97 = 46.9)
        )

        val femaleData = listOf(
            StandardDataEntity(gender = "FEMALE", age = 0, heightP3 = 45.2, heightP10 = 46.9, heightP25 = 48.3, heightP50 = 49.7, heightP75 = 51.1, heightP90 = 52.5, heightP97 = 53.9, weightP3 = 2.3, weightP10 = 2.7, weightP25 = 3.0, weightP50 = 3.2, weightP75 = 3.5, weightP90 = 3.9, weightP97 = 4.6),
            StandardDataEntity(gender = "FEMALE", age = 1, heightP3 = 67.2, heightP10 = 69.8, heightP25 = 72.0, heightP50 = 75.0, heightP75 = 78.0, heightP90 = 80.2, heightP97 = 82.8, weightP3 = 5.8, weightP10 = 6.7, weightP25 = 7.6, weightP50 = 8.7, weightP75 = 9.8, weightP90 = 10.5, weightP97 = 12.4),
            StandardDataEntity(gender = "FEMALE", age = 2, heightP3 = 75.9, heightP10 = 79.1, heightP25 = 81.6, heightP50 = 85.6, heightP75 = 89.6, heightP90 = 92.1, heightP97 = 94.9, weightP3 = 7.9, weightP10 = 9.0, weightP25 = 10.1, weightP50 = 11.3, weightP75 = 12.6, weightP90 = 13.7, weightP97 = 16.2),
            StandardDataEntity(gender = "FEMALE", age = 3, heightP3 = 82.9, heightP10 = 86.6, heightP25 = 89.4, heightP50 = 93.9, heightP75 = 98.4, heightP90 = 101.2, heightP97 = 104.3, weightP3 = 9.6, weightP10 = 11.0, weightP25 = 12.2, weightP50 = 13.3, weightP75 = 14.9, weightP90 = 16.1, weightP97 = 19.0),
            StandardDataEntity(gender = "FEMALE", age = 4, heightP3 = 89.3, heightP10 = 93.3, heightP25 = 96.4, heightP50 = 101.2, heightP75 = 106.0, heightP90 = 109.1, heightP97 = 112.5, weightP3 = 11.2, weightP10 = 12.8, weightP25 = 14.1, weightP50 = 15.0, weightP75 = 16.9, weightP90 = 18.3, weightP97 = 21.5),
            StandardDataEntity(gender = "FEMALE", age = 5, heightP3 = 95.1, heightP10 = 99.5, heightP25 = 102.9, heightP50 = 107.7, heightP75 = 112.5, heightP90 = 115.9, heightP97 = 119.5, weightP3 = 12.6, weightP10 = 14.5, weightP25 = 15.9, weightP50 = 16.6, weightP75 = 18.9, weightP90 = 20.3, weightP97 = 23.9),
            StandardDataEntity(gender = "FEMALE", age = 6, heightP3 = 100.4, heightP10 = 105.1, heightP25 = 108.8, heightP50 = 113.8, heightP75 = 118.8, heightP90 = 122.4, heightP97 = 126.2, weightP3 = 13.9, weightP10 = 16.0, weightP25 = 17.6, weightP50 = 18.1, weightP75 = 20.8, weightP90 = 22.2, weightP97 = 26.3),
            StandardDataEntity(gender = "FEMALE", age = 7, heightP3 = 105.2, heightP10 = 110.2, heightP25 = 114.2, heightP50 = 119.4, heightP75 = 124.6, heightP90 = 128.6, heightP97 = 132.7, weightP3 = 15.2, weightP10 = 17.5, weightP25 = 19.3, weightP50 = 19.6, weightP75 = 22.7, weightP90 = 24.1, weightP97 = 28.7),
            StandardDataEntity(gender = "FEMALE", age = 8, heightP3 = 109.7, heightP10 = 115.0, heightP25 = 119.3, heightP50 = 124.6, heightP75 = 130.0, heightP90 = 134.2, heightP97 = 138.6, weightP3 = 16.4, weightP10 = 19.0, weightP25 = 20.9, weightP50 = 21.1, weightP75 = 24.6, weightP90 = 26.0, weightP97 = 31.0),
            StandardDataEntity(gender = "FEMALE", age = 9, heightP3 = 114.0, heightP10 = 119.6, heightP25 = 124.2, heightP50 = 129.4, heightP75 = 135.2, heightP90 = 139.4, heightP97 = 144.1, weightP3 = 17.6, weightP10 = 20.5, weightP25 = 22.6, weightP50 = 22.6, weightP75 = 26.5, weightP90 = 27.9, weightP97 = 33.4),
            StandardDataEntity(gender = "FEMALE", age = 10, heightP3 = 118.1, heightP10 = 124.0, heightP25 = 128.9, heightP50 = 133.8, heightP75 = 140.0, heightP90 = 144.2, heightP97 = 149.2, weightP3 = 18.8, weightP10 = 22.0, weightP25 = 24.3, weightP50 = 24.1, weightP75 = 28.4, weightP90 = 29.8, weightP97 = 35.7),
            StandardDataEntity(gender = "FEMALE", age = 11, heightP3 = 122.1, heightP10 = 128.3, heightP25 = 133.5, heightP50 = 138.0, heightP75 = 145.6, heightP90 = 148.6, heightP97 = 154.0, weightP3 = 20.0, weightP10 = 23.5, weightP25 = 26.0, weightP50 = 25.6, weightP75 = 30.3, weightP90 = 31.7, weightP97 = 38.1),
            StandardDataEntity(gender = "FEMALE", age = 12, heightP3 = 126.0, heightP10 = 132.4, heightP25 = 138.0, heightP50 = 141.9, heightP75 = 150.8, heightP90 = 152.7, heightP97 = 158.5, weightP3 = 21.2, weightP10 = 25.0, weightP25 = 27.7, weightP50 = 27.1, weightP75 = 32.2, weightP90 = 33.6, weightP97 = 40.5),
            StandardDataEntity(gender = "FEMALE", age = 13, heightP3 = 129.8, heightP10 = 136.3, heightP25 = 142.2, heightP50 = 145.6, heightP75 = 154.5, heightP90 = 156.4, heightP97 = 162.4, weightP3 = 22.4, weightP10 = 26.5, weightP25 = 29.4, weightP50 = 28.6, weightP75 = 34.1, weightP90 = 35.5, weightP97 = 42.9),
            StandardDataEntity(gender = "FEMALE", age = 14, heightP3 = 133.5, heightP10 = 140.1, heightP25 = 146.0, heightP50 = 149.0, heightP75 = 157.8, heightP90 = 159.8, heightP97 = 165.9, weightP3 = 23.6, weightP10 = 28.0, weightP25 = 31.1, weightP50 = 30.1, weightP75 = 36.0, weightP90 = 37.4, weightP97 = 45.3)
        )

        standardDataDao.insertAll(maleData + femaleData)
    }

    suspend fun getDataByGender(gender: String): List<StandardDataEntity> {
        return withContext(Dispatchers.IO) {
            standardDataDao.getDataByGender(gender)
        }
    }

    suspend fun getDataByGenderAndAge(gender: String, age: Int): StandardDataEntity? {
        return withContext(Dispatchers.IO) {
            standardDataDao.getDataByGenderAndAge(gender, age)
        }
    }

    suspend fun getCount(): Int {
        return withContext(Dispatchers.IO) {
            standardDataDao.getCount()
        }
    }
}