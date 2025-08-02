const app = getApp()

Page({
  data: {
    userInfo: {},
    currentBaby: null,
    currentBabyAge: 0,
    babiesList: [],
    currentTheme: 'default',
    themes: [
      { id: 'default', name: '默认主题', color: '#FF6B9D' },
      { id: 'blue', name: '蓝色主题', color: '#667eea' },
      { id: 'green', name: '绿色主题', color: '#4CAF50' },
      { id: 'purple', name: '紫色主题', color: '#9C27B0' }
    ]
  },

  onLoad() {
    this.loadUserInfo()
    this.loadBabiesList()
    this.loadCurrentTheme()
  },

  onShow() {
    this.loadBabiesList()
  },

  loadUserInfo() {
    const userInfo = wx.getStorageSync('userInfo')
    if (userInfo) {
      this.setData({ userInfo })
    }
  },

  loadBabiesList() {
    const userInfo = wx.getStorageSync('userInfo')
    if (!userInfo) {
      wx.redirectTo({ url: '/pages/login/login' })
      return
    }

    wx.request({
      url: `${app.globalData.baseUrl}/babies`,
      method: 'GET',
      data: { userId: userInfo.openId },
      success: (res) => {
        if (res.data.success) {
          const babiesList = res.data.data.map(baby => ({
            ...baby,
            ageInMonths: this.calculateAgeInMonths(baby.birthday)
          }))
          
          this.setData({ babiesList })
          
          // 设置当前宝宝
          const currentBaby = app.globalData.currentBaby
          if (currentBaby) {
            this.setData({ 
              currentBaby,
              currentBabyAge: this.calculateAgeInMonths(currentBaby.birthday)
            })
          } else if (babiesList.length > 0) {
            this.switchBaby({ currentTarget: { dataset: { id: babiesList[0].id } } })
          }
        }
      },
      fail: () => {
        // 模拟数据
        const mockBabies = [
          {
            id: '1',
            nickname: '小宝贝',
            birthday: '2023-06-15',
            ageInMonths: 8
          }
        ]
        this.setData({ babiesList: mockBabies })
        if (mockBabies.length > 0) {
          this.setData({ 
            currentBaby: mockBabies[0],
            currentBabyAge: mockBabies[0].ageInMonths
          })
        }
      }
    })
  },

  calculateAgeInMonths(birthday) {
    const birthDate = new Date(birthday)
    const today = new Date()
    return (today.getFullYear() - birthDate.getFullYear()) * 12 + 
           (today.getMonth() - birthDate.getMonth())
  },

  switchBaby(e) {
    const babyId = e.currentTarget.dataset.id
    const baby = this.data.babiesList.find(b => b.id === babyId)
    
    if (baby) {
      app.globalData.currentBaby = baby
      this.setData({ 
        currentBaby: baby,
        currentBabyAge: baby.ageInMonths
      })
      
      wx.showToast({
        title: `已切换到${baby.nickname}`,
        icon: 'success'
      })
    }
  },

  addBaby() {
    wx.navigateTo({
      url: '/pages/baby-edit/baby-edit'
    })
  },

  editBaby() {
    if (this.data.currentBaby) {
      wx.navigateTo({
        url: `/pages/baby-edit/baby-edit?id=${this.data.currentBaby.id}`
      })
    }
  },

  deleteBaby(e) {
    const babyId = e.currentTarget.dataset.id
    const baby = this.data.babiesList.find(b => b.id === babyId)
    
    wx.showModal({
      title: '确认删除',
      content: `确定要删除宝宝"${baby.nickname}"吗？此操作不可恢复。`,
      success: (res) => {
        if (res.confirm) {
          wx.request({
            url: `${app.globalData.baseUrl}/baby/${babyId}`,
            method: 'DELETE',
            success: (res) => {
              if (res.data.success) {
                wx.showToast({
                  title: '删除成功',
                  icon: 'success'
                })
                this.loadBabiesList()
              }
            },
            fail: () => {
              // 模拟删除
              const newList = this.data.babiesList.filter(b => b.id !== babyId)
              this.setData({ babiesList: newList })
              wx.showToast({
                title: '删除成功',
                icon: 'success'
              })
            }
          })
        }
      }
    })
  },

  showUserInfo() {
    wx.showModal({
      title: '微信信息',
      content: `昵称：${this.data.userInfo.nickName || '未授权'}\n头像：已授权`,
      showCancel: false
    })
  },

  clearCache() {
    wx.showModal({
      title: '清除缓存',
      content: '确定要清除所有缓存数据吗？',
      success: (res) => {
        if (res.confirm) {
          wx.clearStorageSync()
          wx.showToast({
            title: '缓存已清除',
            icon: 'success'
          })
        }
      }
    })
  },

  loadCurrentTheme() {
    const currentTheme = wx.getStorageSync('currentTheme') || 'default'
    this.setData({ currentTheme })
  },

  switchTheme(e) {
    const themeId = e.currentTarget.dataset.theme
    this.setData({ currentTheme: themeId })
    wx.setStorageSync('currentTheme', themeId)
    
    wx.showToast({
      title: '主题切换成功',
      icon: 'success'
    })
  },

  goToTheme() {
    wx.navigateTo({
      url: '/pages/theme/theme'
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