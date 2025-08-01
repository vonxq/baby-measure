const express = require('express')
const { v4: uuidv4 } = require('uuid')
const { getDatabase } = require('../database')

const router = express.Router()

// 用户登录
router.post('/login', (req, res) => {
  const { nickName, avatarUrl, openId, loginTime } = req.body
  
  if (!openId) {
    return res.status(400).json({
      success: false,
      message: '缺少用户标识'
    })
  }

  const db = getDatabase()
  
  // 检查用户是否已存在
  const checkSql = `SELECT * FROM users WHERE open_id = ?`
  
  db.get(checkSql, [openId], (err, user) => {
    if (err) {
      console.error('查询用户失败:', err.message)
      return res.status(500).json({
        success: false,
        message: '登录失败'
      })
    }
    
    if (user) {
      // 用户已存在，更新信息
      const updateSql = `UPDATE users SET nick_name = ?, avatar_url = ?, login_time = ? WHERE open_id = ?`
      
      db.run(updateSql, [nickName, avatarUrl, loginTime, openId], function(err) {
        if (err) {
          console.error('更新用户信息失败:', err.message)
          return res.status(500).json({
            success: false,
            message: '登录失败'
          })
        }
        
        res.json({
          success: true,
          message: '登录成功',
          data: { ...user, nickName, avatarUrl, loginTime }
        })
      })
    } else {
      // 新用户，创建记录
      const userId = uuidv4()
      const insertSql = `INSERT INTO users (id, open_id, nick_name, avatar_url, login_time) VALUES (?, ?, ?, ?, ?)`
      
      db.run(insertSql, [userId, openId, nickName, avatarUrl, loginTime], function(err) {
        if (err) {
          console.error('创建用户失败:', err.message)
          return res.status(500).json({
            success: false,
            message: '登录失败'
          })
        }
        
        res.json({
          success: true,
          message: '注册成功',
          data: { id: userId, openId, nickName, avatarUrl, loginTime }
        })
      })
    }
  })
})

// 获取用户信息
router.get('/:openId', (req, res) => {
  const { openId } = req.params
  const db = getDatabase()
  
  const sql = `SELECT * FROM users WHERE open_id = ?`
  
  db.get(sql, [openId], (err, user) => {
    if (err) {
      console.error('获取用户信息失败:', err.message)
      return res.status(500).json({
        success: false,
        message: '获取用户信息失败'
      })
    }
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: '用户不存在'
      })
    }
    
    res.json({
      success: true,
      data: user
    })
  })
})

module.exports = router 