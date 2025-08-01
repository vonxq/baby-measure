const express = require('express')
const { v4: uuidv4 } = require('uuid')
const { getDatabase } = require('../database')

const router = express.Router()

// 创建宝宝信息
router.post('/', (req, res) => {
  const { nickname, birthday, userId } = req.body
  
  if (!nickname || !birthday || !userId) {
    return res.status(400).json({
      success: false,
      message: '请提供完整的宝宝信息'
    })
  }

  const db = getDatabase()
  const babyId = uuidv4()
  
  const sql = `INSERT INTO babies (id, user_id, nickname, birthday) VALUES (?, ?, ?, ?)`
  
  db.run(sql, [babyId, userId, nickname, birthday], function(err) {
    if (err) {
      console.error('创建宝宝信息失败:', err.message)
      return res.status(500).json({
        success: false,
        message: '创建宝宝信息失败'
      })
    }
    
    res.json({
      success: true,
      message: '宝宝信息创建成功',
      data: {
        id: babyId,
        userId,
        nickname,
        birthday
      }
    })
  })
})

// 获取用户的宝宝列表
router.get('/', (req, res) => {
  const { userId } = req.query
  
  if (!userId) {
    return res.status(400).json({
      success: false,
      message: '请提供用户ID'
    })
  }

  const db = getDatabase()
  
  const sql = `SELECT * FROM babies WHERE user_id = ? ORDER BY created_at DESC`
  
  db.all(sql, [userId], (err, rows) => {
    if (err) {
      console.error('获取宝宝列表失败:', err.message)
      return res.status(500).json({
        success: false,
        message: '获取宝宝列表失败'
      })
    }
    
    res.json({
      success: true,
      data: rows
    })
  })
})

// 获取宝宝信息
router.get('/:id', (req, res) => {
  const { id } = req.params
  const db = getDatabase()
  
  const sql = `SELECT * FROM babies WHERE id = ?`
  
  db.get(sql, [id], (err, row) => {
    if (err) {
      console.error('获取宝宝信息失败:', err.message)
      return res.status(500).json({
        success: false,
        message: '获取宝宝信息失败'
      })
    }
    
    if (!row) {
      return res.status(404).json({
        success: false,
        message: '宝宝信息不存在'
      })
    }
    
    res.json({
      success: true,
      data: row
    })
  })
})

// 更新宝宝信息
router.put('/:id', (req, res) => {
  const { id } = req.params
  const { nickname, birthday } = req.body
  
  if (!nickname || !birthday) {
    return res.status(400).json({
      success: false,
      message: '请提供完整的宝宝信息'
    })
  }

  const db = getDatabase()
  
  const sql = `UPDATE babies SET nickname = ?, birthday = ? WHERE id = ?`
  
  db.run(sql, [nickname, birthday, id], function(err) {
    if (err) {
      console.error('更新宝宝信息失败:', err.message)
      return res.status(500).json({
        success: false,
        message: '更新宝宝信息失败'
      })
    }
    
    if (this.changes === 0) {
      return res.status(404).json({
        success: false,
        message: '宝宝信息不存在'
      })
    }
    
    res.json({
      success: true,
      message: '宝宝信息更新成功'
    })
  })
})

// 删除宝宝信息
router.delete('/:id', (req, res) => {
  const { id } = req.params
  const db = getDatabase()
  
  const sql = `DELETE FROM babies WHERE id = ?`
  
  db.run(sql, [id], function(err) {
    if (err) {
      console.error('删除宝宝信息失败:', err.message)
      return res.status(500).json({
        success: false,
        message: '删除宝宝信息失败'
      })
    }
    
    if (this.changes === 0) {
      return res.status(404).json({
        success: false,
        message: '宝宝信息不存在'
      })
    }
    
    res.json({
      success: true,
      message: '宝宝信息删除成功'
    })
  })
})

module.exports = router 