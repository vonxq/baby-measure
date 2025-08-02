const app = getApp()

Page({
  data: {
    currentTheme: 'default',
    themes: [
      { id: 'default', name: '默认主题', color: '#FF6B9D', desc: '温馨粉色' },
      { id: 'blue', name: '蓝色主题', color: '#667eea', desc: '清新蓝色' },
      { id: 'green', name: '绿色主题', color: '#4CAF50', desc: '自然绿色' },
      { id: 'purple', name: '紫色主题', color: '#9C27B0', desc: '优雅紫色' },
      { id: 'orange', name: '橙色主题', color: '#FF9800', desc: '活力橙色' },
      { id: 'teal', name: '青色主题', color: '#009688', desc: '清新青色' }
    ]
  },

  onLoad() {
    this.loadCurrentTheme()
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

  previewTheme(e) {
    const themeId = e.currentTarget.dataset.theme
    const theme = this.data.themes.find(t => t.id === themeId)
    
    wx.showModal({
      title: theme.name,
      content: theme.desc,
      showCancel: false
    })
  }
}) 