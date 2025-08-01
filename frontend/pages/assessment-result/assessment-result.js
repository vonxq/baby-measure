const app = getApp()

Page({
  data: {
    score: 0,
    rank: 0,
    description: '',
    assessmentAge: 0,
    actualAge: 0
  },

  onLoad(options) {
    // 从URL参数获取评估结果
    this.setData({
      score: parseInt(options.score) || 0,
      rank: parseInt(options.rank) || 0,
      description: decodeURIComponent(options.description) || '',
      assessmentAge: parseInt(options.assessmentAge) || 0,
      actualAge: parseInt(options.actualAge) || 0
    })
  },

  backToHome() {
    wx.switchTab({
      url: '/pages/home/home'
    })
  },

  viewRecords() {
    wx.switchTab({
      url: '/pages/records/records'
    })
  },

  shareResult() {
    wx.showShareMenu({
      withShareTicket: true,
      menus: ['shareAppMessage', 'shareTimeline']
    })
  },

  onShareAppMessage() {
    return {
      title: `我家宝宝${this.data.assessmentAge}个月评估得了${this.data.score}分！`,
      path: '/pages/home/home',
      imageUrl: '/images/share-cover.png'
    }
  }
}) 