const express = require('express')
const { getDatabase } = require('../database')

const router = express.Router()

// 获取评估记录
router.get('/', (req, res) => {
  const { babyId } = req.query
  
  if (!babyId) {
    return res.status(400).json({
      success: false,
      message: '请提供宝宝ID'
    })
  }

  const db = getDatabase()
  
  const sql = `SELECT * FROM assessments WHERE baby_id = ? ORDER BY assessment_date DESC`
  
  db.all(sql, [babyId], (err, rows) => {
    if (err) {
      console.error('获取评估记录失败:', err.message)
      return res.status(500).json({
        success: false,
        message: '获取评估记录失败'
      })
    }
    
    // 处理每条记录
    const records = rows.map(row => {
      // 解析answers字段
      let answers = []
      try {
        answers = JSON.parse(row.answers)
      } catch (e) {
        answers = []
      }
      
      return {
        id: row.id,
        score: row.score,
        rank: row.rank,
        answers: answers,
        assessmentDate: row.assessment_date
      }
    })
    
    res.json({
      success: true,
      data: records
    })
  })
})

// 获取单条评估记录
router.get('/:id', (req, res) => {
  const { id } = req.params
  const db = getDatabase()
  
  const sql = `SELECT * FROM assessments WHERE id = ?`
  
  db.get(sql, [id], (err, row) => {
    if (err) {
      console.error('获取评估记录失败:', err.message)
      return res.status(500).json({
        success: false,
        message: '获取评估记录失败'
      })
    }
    
    if (!row) {
      return res.status(404).json({
        success: false,
        message: '评估记录不存在'
      })
    }
    
    // 解析answers字段
    let answers = []
    try {
      answers = JSON.parse(row.answers)
    } catch (e) {
      answers = []
    }
    
    res.json({
      success: true,
      data: {
        id: row.id,
        babyId: row.baby_id,
        score: row.score,
        rank: row.rank,
        answers: answers,
        assessmentDate: row.assessment_date
      }
    })
  })
})

module.exports = router 