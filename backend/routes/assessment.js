const express = require('express')
const router = express.Router()
const fs = require('fs')
const path = require('path')
const { getDatabase } = require('../database')
const { v4: uuidv4 } = require('uuid')

// 获取评估数据
router.get('/data', (req, res) => {
  try {
    const dataPath = path.join(__dirname, '../data/assessments.json')
    const assessmentData = JSON.parse(fs.readFileSync(dataPath, 'utf8'))
    
    res.json({
      success: true,
      data: assessmentData
    })
  } catch (error) {
    console.error('读取评估数据失败:', error)
    res.status(500).json({
      success: false,
      message: '读取评估数据失败'
    })
  }
})

// 获取指定月龄的评估内容
router.get('/data/:month', (req, res) => {
  try {
    const month = req.params.month
    const dataPath = path.join(__dirname, '../data/assessments.json')
    const assessmentData = JSON.parse(fs.readFileSync(dataPath, 'utf8'))
    
    const assessment = assessmentData.assessments[month]
    if (!assessment) {
      return res.status(404).json({
        success: false,
        message: '该月龄的评估内容不存在'
      })
    }
    
    res.json({
      success: true,
      data: assessment
    })
  } catch (error) {
    console.error('读取评估内容失败:', error)
    res.status(500).json({
      success: false,
      message: '读取评估内容失败'
    })
  }
})

// 提交评估结果
router.post('/', (req, res) => {
  try {
    const { babyId, score, rank, answers, assessmentAge, actualAge, assessmentDate } = req.body
    
    if (!babyId || score === undefined || rank === undefined) {
      return res.status(400).json({
        success: false,
        message: '缺少必要参数'
      })
    }

    const db = getDatabase()
    const assessmentId = uuidv4()
    const answersJson = JSON.stringify(answers)
    
    const sql = `
      INSERT INTO assessments (id, baby_id, score, rank, answers, assessment_age, actual_age, assessment_date)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `
    
    db.run(sql, [assessmentId, babyId, score, rank, answersJson, assessmentAge, actualAge, assessmentDate], function(err) {
      if (err) {
        console.error('保存评估结果失败:', err)
        return res.status(500).json({
          success: false,
          message: '保存评估结果失败'
        })
      }
      
      res.json({
        success: true,
        message: '评估结果保存成功',
        data: { id: assessmentId }
      })
    })
  } catch (error) {
    console.error('保存评估结果失败:', error)
    res.status(500).json({
      success: false,
      message: '保存评估结果失败'
    })
  }
})

// 获取宝宝的评估记录
router.get('/records/:babyId', (req, res) => {
  try {
    const { babyId } = req.params
    
    const db = getDatabase()
    const sql = `
      SELECT id, score, rank, answers, assessment_age, actual_age, assessment_date
      FROM assessments 
      WHERE baby_id = ?
      ORDER BY assessment_date DESC
    `
    
    db.all(sql, [babyId], (err, rows) => {
      if (err) {
        console.error('获取评估记录失败:', err)
        return res.status(500).json({
          success: false,
          message: '获取评估记录失败'
        })
      }
      
      // 解析answers JSON
      const records = rows.map(row => ({
        ...row,
        answers: JSON.parse(row.answers || '[]')
      }))
      
      res.json({
        success: true,
        data: records
      })
    })
  } catch (error) {
    console.error('获取评估记录失败:', error)
    res.status(500).json({
      success: false,
      message: '获取评估记录失败'
    })
  }
})

module.exports = router 