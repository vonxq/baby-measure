const app = getApp()
const api = require('../../utils/api.js')

Page({
  data: {
    babies: [],
    currentBaby: null
  },

  onLoad() {
    this.loadBabies()
  },

  onShow() {
    this.loadBabies()
  },

  loadBabies() {
    const userInfo = app.globalData.userInfo
    if (!userInfo) {
      wx.redirectTo({
        url: '/pages/login/login'
      })
      return
    }

    // 这里应该从后端获取用户的宝宝列表
    // 暂时使用本地存储的数据
    const babies = wx.getStorageSync('babies') || []
    const currentBaby = app.globalData.currentBaby
    
    this.setData({ 
      babies,
      currentBaby
    })
  },

  addBaby() {
    wx.navigateTo({
      url: '/pages/baby-edit/baby-edit'
    })
  },

  editBaby(e) {
    const babyId = e.currentTarget.dataset.id
    wx.navigateTo({
      url: `/pages/baby-edit/baby-edit?id=${babyId}`
    })
  },

  switchBaby(e) {
    const babyId = e.currentTarget.dataset.id
    const baby = this.data.babies.find(b => b.id === babyId)
    
    if (baby) {
      app.globalData.currentBaby = baby
      wx.setStorageSync('currentBaby', baby)
      
      wx.showToast({
        title: '切换成功',
        icon: 'success'
      })
      
      setTimeout(() => {
        wx.navigateBack()
      }, 1500)
    }
  },

  deleteBaby(e) {
    const babyId = e.currentTarget.dataset.id
    const baby = this.data.babies.find(b => b.id === babyId)
    
    wx.showModal({
      title: '确认删除',
      content: `确定要删除宝宝"${baby.nickname}"吗？`,
      success: (res) => {
        if (res.confirm) {
          // 从本地存储中删除
          const babies = this.data.babies.filter(b => b.id !== babyId)
          wx.setStorageSync('babies', babies)
          
          // 如果删除的是当前宝宝，需要重新选择
          if (this.data.currentBaby && this.data.currentBaby.id === babyId) {
            if (babies.length > 0) {
              app.globalData.currentBaby = babies[0]
              wx.setStorageSync('currentBaby', babies[0])
            } else {
              app.globalData.currentBaby = null
              wx.removeStorageSync('currentBaby')
            }
          }
          
          this.setData({ babies })
          
          wx.showToast({
            title: '删除成功',
            icon: 'success'
          })
        }
      }
    })
  }
}) 