const app = getApp()

const api = {
  baseUrl: app.globalData.baseUrl,

  // 创建宝宝信息
  createBaby(babyInfo) {
    return new Promise((resolve, reject) => {
      wx.request({
        url: `${this.baseUrl}/baby`,
        method: 'POST',
        data: babyInfo,
        success: resolve,
        fail: reject
      })
    })
  },

  // 获取统计数据
  getStats(babyId) {
    return new Promise((resolve, reject) => {
      wx.request({
        url: `${this.baseUrl}/stats`,
        method: 'GET',
        data: { babyId },
        success: resolve,
        fail: reject
      })
    })
  },

  // 提交评估结果
  submitAssessment(assessmentData) {
    return new Promise((resolve, reject) => {
      wx.request({
        url: `${this.baseUrl}/assessment`,
        method: 'POST',
        data: assessmentData,
        success: resolve,
        fail: reject
      })
    })
  },

  // 获取评估记录
  getRecords(babyId) {
    return new Promise((resolve, reject) => {
      wx.request({
        url: `${this.baseUrl}/assessment/records/${babyId}`,
        method: 'GET',
        success: resolve,
        fail: reject
      })
    })
  },

  // 获取评估数据
  getAssessmentData() {
    return new Promise((resolve, reject) => {
      wx.request({
        url: `${this.baseUrl}/assessment/data`,
        method: 'GET',
        success: resolve,
        fail: reject
      })
    })
  },

  // 获取指定月龄的评估内容
  getAssessmentByMonth(month) {
    return new Promise((resolve, reject) => {
      wx.request({
        url: `${this.baseUrl}/assessment/data/${month}`,
        method: 'GET',
        success: resolve,
        fail: reject
      })
    })
  }
}

module.exports = api 