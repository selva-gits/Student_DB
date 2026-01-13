import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000';

const api = axios.create({
  baseURL: API_BASE_URL,
});

// Add token to requests
api.interceptors.request.use((config) => {
    const token = localStorage.getItem('token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

// Auth Services
export const authService = {
    login: (email, password) => api.post('/auth/login', { email, password }),
    register: (userData) => api.post('/auth/register', userData),
};

// Student Services
export const studentService = {
    getAllStudents: (page = 1, limit = 20) => api.get(`/students?page=${page}&limit=${limit}`),
    getStudentById: (id) => api.get(`/students/${id}`),
    getStudentAnalytics: (id) => api.get(`/students/${id}/analytics`),
};

// Course Services
export const courseService = {
    getAllCourses: () => api.get('/courses'),
    getCourseOfferings: () => api.get('/courses/offerings'),
    getAssignments: (offeringId) => api.get(`/courses/offerings/${offeringId}/assignments`),
    submitAssignment: (data) => api.post('/courses/assignments/submit', data),
};

export default api;
