import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import apiClient from '../api/apiClient';

export interface Teacher {
  id: number;
  name: string;
  email: string | null;
  phone: string;
  picProfile: string | null;
  dob: string | null;
}

interface TeachersState {
  teachers: Teacher[];
  loading: boolean;
  error: string | null;
}

const initialState: TeachersState = {
  teachers: [],
  loading: false,
  error: null,
};

export const fetchGlobalTeachers = createAsyncThunk(
  'teachers/fetchGlobalTeachers',
  async (_, { rejectWithValue }) => {
    try {
      // Endpoint currently exists in classRouter
      const response = await apiClient.get('/class/teachers');
      return response.data.teachers;
    } catch (err: any) {
      return rejectWithValue(err.response?.data?.message || 'Failed to fetch teachers');
    }
  }
);

export const updateTeacherProfile = createAsyncThunk(
  'teachers/updateTeacherProfile',
  async (
    payload: { id: string | number; name?: string; email?: string; phone?: string; password?: string; picProfile?: string; dob?: string },
    { rejectWithValue }
  ) => {
    try {
      const { id, ...data } = payload;
      const response = await apiClient.put(`/auth/update/${id}`, data);
      return response.data;
    } catch (err: any) {
      return rejectWithValue(err.response?.data?.message || 'Failed to update teacher profile');
    }
  }
);

export const teachersSlice = createSlice({
  name: 'teachers',
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchGlobalTeachers.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchGlobalTeachers.fulfilled, (state, action) => {
        state.loading = false;
        state.teachers = action.payload || [];
      })
      .addCase(fetchGlobalTeachers.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      });
  },
});

export default teachersSlice.reducer;
