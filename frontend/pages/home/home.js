const app = getApp()

Page({
  data: {
    currentBaby: null,
    babyAge: 0,
    timelineData: []
  },

  onLoad() {
    this.checkLoginAndBaby()
  },

  onShow() {
    this.loadCurrentBaby()
    this.loadTimelineData()
  },

  checkLoginAndBaby() {
    if (!app.isLoggedIn()) {
      wx.redirectTo({
        url: '/pages/login/login'
      })
      return
    }

    if (!app.hasCurrentBaby()) {
      wx.redirectTo({
        url: '/pages/welcome/welcome'
      })
      return
    }
  },

  loadCurrentBaby() {
    const currentBaby = app.globalData.currentBaby
    if (currentBaby) {
      this.setData({
        currentBaby: currentBaby
      })
      this.calculateAge()
    }
  },

  calculateAge() {
    if (!this.data.currentBaby) return
    
    const birthday = new Date(this.data.currentBaby.birthday)
    const today = new Date()
    const ageInMonths = (today.getFullYear() - birthday.getFullYear()) * 12 + 
                        (today.getMonth() - birthday.getMonth())
    
    this.setData({
      babyAge: ageInMonths
    })
  },

  loadTimelineData() {
    if (!this.data.currentBaby) return

    // 从后端API获取时间轴数据
    wx.request({
      url: `${app.globalData.baseUrl}/records`,
      method: 'GET',
      data: {
        babyId: this.data.currentBaby.id
      },
      success: (res) => {
        if (res.data.success && res.data.data) {
          const timelineData = res.data.data.map(record => ({
            id: record.id,
            day: new Date(record.assessmentDate).getDate().toString(),
            month: `${new Date(record.assessmentDate).getMonth() + 1}月`,
            title: `${record.assessmentAge || this.data.babyAge}个月评估`,
            age: record.assessmentAge || this.data.babyAge,
            score: record.score,
            rank: record.rank,
            icon: '📊',
            date: record.assessmentDate
          }))
          
          this.setData({ timelineData })
        } else {
          console.error('获取时间轴数据失败:', res.data)
          this.setData({ timelineData: [] })
        }
      },
      fail: (err) => {
        console.error('请求时间轴数据失败:', err)
        this.setData({ timelineData: [] })
      }
    })
  },

  switchBaby() {
    wx.switchTab({
      url: '/pages/settings/settings'
    })
  },

  startAssessment() {
    if (!this.data.currentBaby) {
      wx.showToast({
        title: '请先选择宝宝',
        icon: 'none'
      })
      return
    }
    
    wx.navigateTo({
      url: '/pages/assessment/assessment'
    })
  },

  viewRecords() {
    wx.switchTab({
      url: '/pages/records/records'
    })
  }
}) 