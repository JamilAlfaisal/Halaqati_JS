import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

import apiClient from '../api/apiClient';

interface ClassData {
  id: number;
  name: string;
  description: string;
  days: string[];
  startTime: string;
  endTime: string;
  location: string;
  teacherId: number;
  teacherName?: string;
  studentsCount?: number;
}

export interface Teacher {
  id: number;
  name: string;
  phone: string;
  email: string;
  picProfile?: string;
}

interface ClassesState {
  classes: ClassData[];
  teachers: Teacher[];
  loading: boolean;
  error: string | null;
}

const initialState: ClassesState = {
  classes: [],
  teachers: [],
  loading: false,
  error: null,
};

export const fetchAllTeachers = createAsyncThunk(
  'classes/fetchTeachers',
  async (_, { rejectWithValue }) => {
    try {
      const response = await apiClient.get('/class/teachers');
      return response.data.teachers;
    } catch (err: any) {
      return rejectWithValue(err.response?.data?.message || 'Failed to fetch teachers');
    }
  }
);

export const fetchAllClasses = createAsyncThunk(
  'classes/fetchAll',
  async (_, { rejectWithValue }) => {
    try {
      const response = await apiClient.get('/class/all');
      return response.data.classes;
    } catch (err: any) {
      return rejectWithValue(err.response?.data?.message || 'Failed to fetch classes');
    }
  }
);

export const createClass = createAsyncThunk(
  'classes/create',
  async (classData: Partial<ClassData>, { rejectWithValue }) => {
    try {
      const response = await apiClient.post('/class/create', classData);
      return response.data;
    } catch (err: any) {
      return rejectWithValue(err.response?.data?.message || 'Failed to create class');
    }
  }
);

export const updateClass = createAsyncThunk(
  'classes/update',
  async ({ id, data }: { id: number; data: Partial<ClassData> }, { rejectWithValue }) => {
    try {
      const response = await apiClient.put(`/class/update/${id}`, data);
      return response.data;
    } catch (err: any) {
      return rejectWithValue(err.response?.data?.message || 'Failed to update class');
    }
  }
);

export const deleteClass = createAsyncThunk(
  'classes/delete',
  async (id: number, { rejectWithValue }) => {
    try {
      await apiClient.delete(`/class/delete/${id}`);
      return id;
    } catch (err: any) {
      return rejectWithValue(err.response?.data?.message || 'Failed to delete class');
    }
  }
);

export const fetchAttendanceStats = createAsyncThunk(
  'classes/fetchAttendanceStats',
  async ({ classId, startDate, endDate }: { classId: number; startDate: string; endDate: string }, { rejectWithValue }) => {
    try {
      const response = await apiClient.get(`/attendance/admin/count/${classId}?startDate=${startDate}&endDate=${endDate}`);
      return { classId, data: response.data.students };
    } catch (err: any) {
      return rejectWithValue(err.response?.data?.message || 'Failed to fetch attendance stats');
    }
  }
);

export const fetchGradesStats = createAsyncThunk(
  'classes/fetchGradesStats',
  async ({ classId, startDate, endDate }: { classId: number; startDate: string; endDate: string }, { rejectWithValue }) => {
    try {
      const response = await apiClient.get(`/grades/admin/stats/${classId}?startDate=${startDate}&endDate=${endDate}`);
      return { classId, data: response.data.students };
    } catch (err: any) {
      return rejectWithValue(err.response?.data?.message || 'Failed to fetch grades stats');
    }
  }
);

export const fetchPageProgressSummary = createAsyncThunk(
  'classes/fetchPageProgressSummary',
  async (classId: number, { rejectWithValue }) => {
    try {
      const response = await apiClient.get(`/pages/admin/class/${classId}/summary`);
      return { classId, data: response.data.students };
    } catch (err: any) {
      return rejectWithValue(err.response?.data?.message || 'Failed to fetch page progress summary');
    }
  }
);

export const fetchStudentPageProgress = createAsyncThunk(
  'classes/fetchStudentPageProgress',
  async ({ classId, studentId }: { classId: number; studentId: string }, { rejectWithValue }) => {
    try {
      const response = await apiClient.get(`/pages/admin/student/${studentId}/class/${classId}/progress`);
      return { studentId, data: response.data.progress };
    } catch (err: any) {
      return rejectWithValue(err.response?.data?.message || 'Failed to fetch student page progress');
    }
  }
);

export const classesSlice = createSlice({
  name: 'classes',
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      // Fetch All
      .addCase(fetchAllClasses.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchAllClasses.fulfilled, (state, action) => {
        state.loading = false;
        state.classes = action.payload;
      })
      .addCase(fetchAllClasses.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      })
      // Fetch Teachers
      .addCase(fetchAllTeachers.fulfilled, (state, action) => {
        state.teachers = action.payload;
      })
      // Create
      .addCase(createClass.fulfilled, (state, action) => {
        state.classes.push(action.payload);
      })
      // Update
      .addCase(updateClass.fulfilled, (state, action) => {
        const index = state.classes.findIndex(c => c.id === action.payload.id);
        if (index !== -1) {
          state.classes[index] = action.payload;
        }
      })
      // Delete
      .addCase(deleteClass.fulfilled, (state, action) => {
        state.classes = state.classes.filter(c => c.id !== action.payload);
      });
  },
});

export default classesSlice.reducer;
