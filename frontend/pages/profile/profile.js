const app = getApp()

Page({
  data: {
    userInfo: null,
    currentBaby: null,
    babyAgeText: ''
  },

  onLoad() {
    this.checkLogin()
  },

  onShow() {
    this.loadUserInfo()
    this.loadCurrentBaby()
  },

  checkLogin() {
    if (!app.isLoggedIn()) {
      wx.redirectTo({
        url: '/pages/login/login'
      })
      return
    }
  },

  loadUserInfo() {
    const userInfo = app.globalData.userInfo
    if (userInfo) {
      this.setData({ userInfo })
    }
  },

  loadCurrentBaby() {
    const currentBaby = app.globalData.currentBaby
    if (currentBaby) {
      this.setData({ currentBaby })
      this.calculateAge()
    }
  },

  calculateAge() {
    if (!this.data.currentBaby) return
    
    const birthday = new Date(this.data.currentBaby.birthday)
    const today = new Date()
    const ageInMonths = (today.getFullYear() - birthday.getFullYear()) * 12 + 
                        (today.getMonth() - birthday.getMonth())
    
    let ageText = ''
    if (ageInMonths < 12) {
      ageText = `${ageInMonths}个月`
    } else {
      const years = Math.floor(ageInMonths / 12)
      const months = ageInMonths % 12
      if (months === 0) {
        ageText = `${years}岁`
      } else {
        ageText = `${years}岁${months}个月`
      }
    }
    
    this.setData({ babyAgeText: ageText })
  },

  editUserInfo() {
    wx.navigateTo({
      url: '/pages/user-edit/user-edit'
    })
  },

  switchBaby() {
    wx.navigateTo({
      url: '/pages/baby-manage/baby-manage'
    })
  },

  goToSettings() {
    wx.navigateTo({
      url: '/pages/settings/settings'
    })
  },

  logout() {
    wx.showModal({
      title: '确认退出',
      content: '确定要退出登录吗？',
      success: (res) => {
        if (res.confirm) {
          app.logout()
          wx.redirectTo({
            url: '/pages/login/login'
          })
        }
      }
    })
  }
}) 