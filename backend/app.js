const express = require('express')
const cors = require('cors')
const bodyParser = require('body-parser')
const { initDatabase } = require('./database')
const userRoutes = require('./routes/user')
const babyRoutes = require('./routes/baby')
const assessmentRoutes = require('./routes/assessment')
const statsRoutes = require('./routes/stats')
const recordsRoutes = require('./routes/records')

const app = express()
const PORT = process.env.PORT || 3000

// 中间件
app.use(cors())
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

// 路由
app.use('/api/user', userRoutes)
app.use('/api/baby', babyRoutes)
app.use('/api/assessment', assessmentRoutes)
app.use('/api/stats', statsRoutes)
app.use('/api/records', recordsRoutes)

// 健康检查
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Baby Growth Assessment API is running' })
})

// 错误处理中间件
app.use((err, req, res, next) => {
  console.error(err.stack)
  res.status(500).json({
    success: false,
    message: '服务器内部错误',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  })
})

// 404处理
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: '接口不存在'
  })
})

// 初始化数据库并启动服务器
initDatabase().then(() => {
  app.listen(PORT, () => {
    console.log(`服务器运行在端口 ${PORT}`)
    console.log(`健康检查: http://localhost:${PORT}/health`)
  })
}).catch(err => {
  console.error('数据库初始化失败:', err)
  process.exit(1)
}) 