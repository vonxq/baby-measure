const app = getApp()
const api = require('../../utils/api.js')

Page({
  data: {
    records: []
  },

  onLoad() {
    this.loadRecords()
  },

  onShow() {
    this.loadRecords()
  },

  loadRecords() {
    const babyInfo = app.globalData.currentBaby
    if (!babyInfo) {
      wx.redirectTo({
        url: '/pages/welcome/welcome'
      })
      return
    }

    api.getRecords(babyInfo.id).then(res => {
      if (res.data.success) {
        const records = res.data.data.map(record => ({
          ...record,
          assessmentDate: this.formatDate(record.assessment_date),
          actualAge: record.actual_age,
          assessmentAge: record.assessment_age
        }))
        
        this.setData({ records })
        this.drawChart()
      } else {
        console.error('获取记录失败:', res.data)
        wx.showToast({
          title: '获取记录失败',
          icon: 'none'
        })
      }
    }).catch(err => {
      console.error('请求记录失败:', err)
      // 如果没有记录，显示空状态
      this.setData({ records: [] })
      this.drawChart()
    })
  },

  formatDate(dateString) {
    const date = new Date(dateString)
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
  },

  calculateAgeInMonths(assessmentDate) {
    const currentBaby = app.globalData.currentBaby
    const birthday = new Date(currentBaby.birthday)
    const assessment = new Date(assessmentDate)
    return (assessment.getFullYear() - birthday.getFullYear()) * 12 + 
           (assessment.getMonth() - birthday.getMonth())
  },

  drawChart() {
    if (this.data.records.length === 0) return

    const ctx = wx.createCanvasContext('growthChart')
    const canvasWidth = 300
    const canvasHeight = 200
    const padding = 40

    // 清空画布
    ctx.clearRect(0, 0, canvasWidth, canvasHeight)

    // 绘制坐标轴
    ctx.beginPath()
    ctx.setStrokeStyle('#E0E0E0')
    ctx.setLineWidth(1)
    ctx.moveTo(padding, padding)
    ctx.lineTo(padding, canvasHeight - padding)
    ctx.lineTo(canvasWidth - padding, canvasHeight - padding)
    ctx.stroke()

    // 绘制数据点
    const dataPoints = this.data.records.map((record, index) => ({
      x: padding + (index / (this.data.records.length - 1)) * (canvasWidth - 2 * padding),
      y: canvasHeight - padding - (record.score / 25) * (canvasHeight - 2 * padding)
    }))

    // 绘制连线
    ctx.beginPath()
    ctx.setStrokeStyle('#FFB6C1')
    ctx.setLineWidth(3)
    dataPoints.forEach((point, index) => {
      if (index === 0) {
        ctx.moveTo(point.x, point.y)
      } else {
        ctx.lineTo(point.x, point.y)
      }
    })
    ctx.stroke()

    // 绘制数据点
    ctx.setFillStyle('#FF69B4')
    dataPoints.forEach(point => {
      ctx.beginPath()
      ctx.arc(point.x, point.y, 4, 0, 2 * Math.PI)
      ctx.fill()
    })

    ctx.draw()
  },

  goToAssessment() {
    wx.navigateTo({
      url: '/pages/assessment/assessment'
    })
  }
}) 