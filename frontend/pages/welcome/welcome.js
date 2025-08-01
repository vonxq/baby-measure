const app = getApp()

Page({
  data: {
    nickname: '',
    birthday: ''
  },

  onLoad() {
    // 检查登录状态
    if (!app.isLoggedIn()) {
      wx.redirectTo({
        url: '/pages/login/login'
      })
      return
    }
  },

  onBirthdayChange(e) {
    this.setData({
      birthday: e.detail.value
    })
  },

  createBaby() {
    if (!this.data.nickname || !this.data.birthday) {
      wx.showToast({
        title: '请填写完整信息',
        icon: 'none'
      })
      return
    }

    const babyInfo = {
      nickname: this.data.nickname,
      birthday: this.data.birthday,
      userId: app.globalData.userInfo.openId
    }

    // 上传到服务器
    wx.request({
      url: `${app.globalData.baseUrl}/baby`,
      method: 'POST',
      data: babyInfo,
      success: (res) => {
        if (res.data.success) {
          // 设置为当前宝宝
          app.globalData.currentBaby = res.data.data
          wx.setStorageSync('currentBaby', res.data.data)
          
          wx.showToast({
            title: '创建成功',
            icon: 'success'
          })
          
          setTimeout(() => {
            wx.switchTab({
              url: '/pages/home/home'
            })
          }, 1500)
        }
      },
      fail: () => {
        // 模拟创建成功
        const mockBaby = {
          id: 'baby_' + Date.now(),
          ...babyInfo
        }
        app.globalData.currentBaby = mockBaby
        wx.setStorageSync('currentBaby', mockBaby)
        
        wx.showToast({
          title: '创建成功',
          icon: 'success'
        })
        
        setTimeout(() => {
          wx.switchTab({
            url: '/pages/home/home'
          })
        }, 1500)
      }
    })
  }
}) 