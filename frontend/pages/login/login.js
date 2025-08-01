const app = getApp()

Page({
  data: {
    hasUserInfo: false
  },

  onLoad() {
    // 检查是否已经登录
    const userInfo = wx.getStorageSync('userInfo')
    if (userInfo) {
      this.checkLoginStatus()
    }
  },

  checkLoginStatus() {
    const userInfo = wx.getStorageSync('userInfo')
    if (userInfo) {
      app.globalData.userInfo = userInfo
      
      // 检查是否有宝宝信息
      const babies = wx.getStorageSync('babies')
      if (babies && babies.length > 0) {
        app.globalData.currentBaby = babies[0]
        wx.switchTab({
          url: '/pages/home/home'
        })
      } else {
        wx.redirectTo({
          url: '/pages/welcome/welcome'
        })
      }
    }
  },

  onGetUserInfo(e) {
    if (e.detail.userInfo) {
      // 用户同意授权
      const userInfo = {
        ...e.detail.userInfo,
        openId: this.generateOpenId(), // 模拟openId
        loginTime: new Date().toISOString()
      }
      
      // 保存用户信息
      wx.setStorageSync('userInfo', userInfo)
      app.globalData.userInfo = userInfo
      
      // 上传用户信息到服务器
      this.uploadUserInfo(userInfo)
      
      wx.showToast({
        title: '登录成功',
        icon: 'success'
      })
      
      // 跳转到欢迎页面
      setTimeout(() => {
        wx.redirectTo({
          url: '/pages/welcome/welcome'
        })
      }, 1500)
      
    } else {
      // 用户拒绝授权
      wx.showToast({
        title: '需要授权才能使用',
        icon: 'none'
      })
    }
  },

  uploadUserInfo(userInfo) {
    wx.request({
      url: `${app.globalData.baseUrl}/user/login`,
      method: 'POST',
      data: userInfo,
      success: (res) => {
        if (res.data.success) {
          console.log('用户信息上传成功')
        }
      },
      fail: () => {
        console.log('用户信息上传失败，使用本地存储')
      }
    })
  },

  generateOpenId() {
    // 生成模拟的openId
    return 'openid_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9)
  }
}) 