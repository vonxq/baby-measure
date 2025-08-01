App({
  globalData: {
    userInfo: null,
    currentBaby: null,
    // 使用微信开发者工具的本地调试
    baseUrl: 'http://127.0.0.1:3000/api'
  },

  onLaunch() {
    // 检查登录状态
    this.checkLoginStatus()
  },

  checkLoginStatus() {
    const userInfo = wx.getStorageSync('userInfo')
    if (userInfo) {
      this.globalData.userInfo = userInfo
      
      // 检查是否有宝宝信息
      const currentBaby = wx.getStorageSync('currentBaby')
      if (currentBaby) {
        this.globalData.currentBaby = currentBaby
      }
    } else {
      // 未登录，跳转到登录页面
      wx.redirectTo({
        url: '/pages/login/login'
      })
    }
  },

  // 检查是否已登录
  isLoggedIn() {
    return !!this.globalData.userInfo
  },

  // 检查是否有当前宝宝
  hasCurrentBaby() {
    return !!this.globalData.currentBaby
  }
}) 