import React, { useState, useEffect } from 'react';
import { 
  Dialog, DialogTitle, DialogContent, DialogActions, Button, 
  TextField, Box, CircularProgress, Alert
} from '@mui/material';
import { useDispatch } from 'react-redux';
import { updateStudentProfile, fetchGlobalStudentDirectory } from '../redux/studentsSlice';
import apiClient from '../api/apiClient';
import type { AppDispatch } from '../redux/store';

interface EditStudentDialogProps {
  open: boolean;
  studentId: string | null;
  onClose: () => void;
}

const EditStudentDialog: React.FC<EditStudentDialogProps> = ({ open, studentId, onClose }) => {
  const dispatch = useDispatch<AppDispatch>();
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [formData, setFormData] = useState({
    name: '',
    phone: '',
    email: '',
    dob: '',
    picProfile: '',
    password: '',
  });

  useEffect(() => {
    if (open && studentId) {
      setLoading(true);
      setError(null);
      // Fetch current student profile
      apiClient.get(`/auth/user/${studentId}`)
        .then(res => {
          const user = res.data;
          setFormData({
            name: user.name || '',
            phone: user.phone || '',
            email: user.email || '',
            dob: user.dob ? user.dob.split('T')[0] : '', // Format for date input
            picProfile: user.picProfile || '',
            password: '', // Keep empty unless changing
          });
        })
        .catch(err => {
          setError(err.response?.data?.message || 'فشل في تحميل بيانات الطالب');
        })
        .finally(() => setLoading(false));
    }
  }, [open, studentId]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSave = async () => {
    if (!studentId) return;
    setSaving(true);
    setError(null);
    try {
      // Only send password if it was typed
      const payload: any = { id: studentId, ...formData };
      if (!payload.password) {
        delete payload.password;
      }
      
      await dispatch(updateStudentProfile(payload)).unwrap();
      await dispatch(fetchGlobalStudentDirectory()); // Refresh directory
      onClose();
    } catch (err: any) {
      setError(err);
    } finally {
      setSaving(false);
    }
  };

  return (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="sm">
      <DialogTitle sx={{ fontWeight: 'bold' }}>تعديل بيانات الطالب</DialogTitle>
      <DialogContent dividers>
        {loading ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}>
            <CircularProgress />
          </Box>
        ) : (
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, pt: 1 }}>
            {error && <Alert severity="error">{error}</Alert>}
            
            <TextField 
              label="الاسم الكامل" 
              name="name" 
              value={formData.name} 
              onChange={handleChange} 
              fullWidth 
              required 
            />
            
            <TextField 
              label="رقم الهاتف" 
              name="phone" 
              value={formData.phone} 
              onChange={handleChange} 
              fullWidth 
              required 
            />
            
            <TextField 
              label="البريد الإلكتروني" 
              name="email" 
              type="email"
              value={formData.email} 
              onChange={handleChange} 
              fullWidth 
            />
            
            <TextField 
              label="تاريخ الميلاد" 
              name="dob" 
              type="date"
              value={formData.dob} 
              onChange={handleChange} 
              fullWidth 
            />
            
            <TextField 
              label="رابط الصورة الشخصية" 
              name="picProfile" 
              value={formData.picProfile} 
              onChange={handleChange} 
              fullWidth 
            />

            <TextField 
              label="كلمة المرور الجديدة (اختياري)" 
              name="password" 
              type="password"
              value={formData.password} 
              onChange={handleChange} 
              placeholder="اتركه فارغاً للاحتفاظ بكلمة المرور الحالية"
              fullWidth 
            />
          </Box>
        )}
      </DialogContent>
      <DialogActions sx={{ p: 2 }}>
        <Button onClick={onClose} disabled={saving}>إلغاء</Button>
        <Button 
          onClick={handleSave} 
          variant="contained" 
          disabled={loading || saving || !formData.name || !formData.phone}
        >
          {saving ? <CircularProgress size={24} color="inherit" /> : 'حفظ التعديلات'}
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default EditStudentDialog;
