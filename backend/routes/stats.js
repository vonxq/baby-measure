const express = require('express')
const { getDatabase } = require('../database')

const router = express.Router()

// 获取统计数据
router.get('/', (req, res) => {
  const { babyId } = req.query
  
  if (!babyId) {
    return res.status(400).json({
      success: false,
      message: '请提供宝宝ID'
    })
  }

  const db = getDatabase()
  
  // 获取评估次数
  const countSql = `SELECT COUNT(*) as total FROM assessments WHERE baby_id = ?`
  
  // 获取平均分数
  const avgSql = `SELECT AVG(score) as average FROM assessments WHERE baby_id = ?`
  
  // 获取最近评估
  const recentSql = `SELECT assessment_date FROM assessments WHERE baby_id = ? ORDER BY assessment_date DESC LIMIT 1`
  
  db.get(countSql, [babyId], (err, countRow) => {
    if (err) {
      console.error('获取评估次数失败:', err.message)
      return res.status(500).json({
        success: false,
        message: '获取统计数据失败'
      })
    }
    
    db.get(avgSql, [babyId], (err, avgRow) => {
      if (err) {
        console.error('获取平均分数失败:', err.message)
        return res.status(500).json({
          success: false,
          message: '获取统计数据失败'
        })
      }
      
      db.get(recentSql, [babyId], (err, recentRow) => {
        if (err) {
          console.error('获取最近评估失败:', err.message)
          return res.status(500).json({
            success: false,
            message: '获取统计数据失败'
          })
        }
        
        const totalAssessments = countRow ? countRow.total : 0
        const averageScore = avgRow && avgRow.average ? Math.round(avgRow.average * 10) / 10 : 0
        const lastAssessment = recentRow ? recentRow.assessment_date : null
        
        res.json({
          success: true,
          data: {
            totalAssessments,
            averageScore,
            lastAssessment: lastAssessment ? new Date(lastAssessment).toLocaleDateString() : '暂无'
          }
        })
      })
    })
  })
})

module.exports = router 