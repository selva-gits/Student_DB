import React, { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import { studentService } from '../services/api';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import './Dashboard.css';

const StudentDashboard = () => {
    const { user, logout } = useAuth();
    const [analytics, setAnalytics] = useState(null);
    const [loading, setLoading] = useState(true);
    const [readModeActive, setReadModeActive] = useState(false);

    useEffect(() => {
        fetchAnalytics();
    }, []);

    const fetchAnalytics = async () => {
        try {
            const response = await studentService.getStudentAnalytics(user.user_id);
            setAnalytics(response.data);
        } catch (error) {
            console.error('Failed to fetch analytics:', error);
        } finally {
            setLoading(false);
        }
    };

    const toggleReadMode = () => {
        setReadModeActive(!readModeActive);
        // In a real app, this would track start/end time and send to backend
    };

    const chartData = analytics ? [
        { name: 'Screen Time', hours: parseFloat(analytics.screen_time?.avg_daily_hours || 0) },
        { name: 'Read Time', hours: parseFloat(analytics.read_mode?.total_read_hours || 0) },
    ] : [];

    if (readModeActive) {
        return (
            <div className="read-mode">
                <div className="read-mode-header">
                    <h2>📖 Read Mode Active</h2>
                    <button onClick={toggleReadMode}>Exit Read Mode</button>
                </div>
                <div className="read-mode-content">
                    <h1>Course Material</h1>
                    <p>This is a simulated reading environment. In a real application, course PDFs or content would be displayed here.</p>
                    <p>Your reading time is being tracked for analytics.</p>
                </div>
            </div>
        );
    }

    return (
        <div className="dashboard">
            <nav className="dashboard-nav">
                <h1>Student ERP</h1>
                <div className="nav-actions">
                    <span>Welcome, {user?.full_name || 'Student'}</span>
                    <button onClick={logout} className="logout-btn">Logout</button>
                </div>
            </nav>

            <div className="dashboard-content">
                <div className="stats-grid">
                    <div className="stat-card">
                        <h3>🖥️ Avg Daily Screen Time</h3>
                        <p className="stat-value">
                            {analytics?.screen_time?.avg_daily_hours || '0'} hrs
                        </p>
                    </div>

                    <div className="stat-card">
                        <h3>📚 Total Read Time</h3>
                        <p className="stat-value">
                            {analytics?.read_mode?.total_read_hours || '0'} hrs
                        </p>
                    </div>

                    <div className="stat-card">
                        <h3>📖 Read Sessions</h3>
                        <p className="stat-value">
                            {analytics?.read_mode?.total_sessions || '0'}
                        </p>
                    </div>
                </div>

                <div className="chart-section">
                    <h2>Activity Analytics</h2>
                    <ResponsiveContainer width="100%" height={300}>
                        <BarChart data={chartData}>
                            <CartesianGrid strokeDasharray="3 3" />
                            <XAxis dataKey="name" />
                            <YAxis label={{ value: 'Hours', angle: -90, position: 'insideLeft' }} />
                            <Tooltip />
                            <Legend />
                            <Bar dataKey="hours" fill="#667eea" />
                        </BarChart>
                    </ResponsiveContainer>
                </div>

                <div className="actions-section">
                    <button className="primary-btn" onClick={toggleReadMode}>
                        📖 Enter Read Mode
                    </button>
                </div>
            </div>
        </div>
    );
};

export default StudentDashboard;
