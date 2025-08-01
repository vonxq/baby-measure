const sqlite3 = require('sqlite3').verbose()
const path = require('path')

const dbPath = path.join(__dirname, 'baby_assessment.db')
let db

function initDatabase() {
  return new Promise((resolve, reject) => {
    db = new sqlite3.Database(dbPath, (err) => {
      if (err) {
        console.error('数据库连接失败:', err.message)
        reject(err)
        return
      }
      console.log('数据库连接成功')
      createTables().then(resolve).catch(reject)
    })
  })
}

function createTables() {
  return new Promise((resolve, reject) => {
    const tables = [
      // 用户表
      `CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        open_id TEXT UNIQUE NOT NULL,
        nick_name TEXT,
        avatar_url TEXT,
        login_time DATETIME DEFAULT CURRENT_TIMESTAMP,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )`,
      
      // 宝宝信息表
      `CREATE TABLE IF NOT EXISTS babies (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        nickname TEXT NOT NULL,
        birthday TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )`,
      
      // 评估记录表
      `CREATE TABLE IF NOT EXISTS assessments (
        id TEXT PRIMARY KEY,
        baby_id TEXT NOT NULL,
        score INTEGER NOT NULL,
        rank INTEGER NOT NULL,
        answers TEXT,
        assessment_age INTEGER NOT NULL,
        actual_age INTEGER NOT NULL,
        assessment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (baby_id) REFERENCES babies (id)
      )`
    ]

    let completed = 0
    const total = tables.length

    tables.forEach((sql, index) => {
      db.run(sql, (err) => {
        if (err) {
          console.error(`创建表 ${index + 1} 失败:`, err.message)
          reject(err)
          return
        }
        
        completed++
        if (completed === total) {
          console.log('所有数据表创建完成')
          resolve()
        }
      })
    })
  })
}

function getDatabase() {
  return db
}

module.exports = {
  initDatabase,
  getDatabase
} 