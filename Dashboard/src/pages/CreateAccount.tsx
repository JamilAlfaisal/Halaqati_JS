import React, { useState } from 'react';
import { useFormik } from 'formik';
import * as Yup from 'yup';
import { Box, Typography, TextField, Button, Paper, Tabs, Tab, Alert, Snackbar } from '@mui/material';
import apiClient from '../api/apiClient';

const validationSchema = Yup.object({
  name: Yup.string().required('الاسم مطلوب'),
  phone: Yup.string().required('رقم الهاتف مطلوب'),
  password: Yup.string().min(6, 'كلمة المرور يجب أن تكون 6 أحرف على الأقل').required('كلمة المرور مطلوبة'),
  dob: Yup.date().required('تاريخ الميلاد مطلوب'),
});

const CreateAccount: React.FC = () => {
  const [role, setRole] = useState<'teacher' | 'student'>('teacher');
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const formik = useFormik({
    initialValues: {
      name: '',
      phone: '',
      password: '',
      dob: '',
    },
    validationSchema,
    onSubmit: async (values, { resetForm }) => {
      try {
        setError(null);
        await apiClient.post('/auth/admin/create-account', {
          ...values,
          role,
        });
        setSuccess(true);
        resetForm();
      } catch (err: any) {
        setError(err.response?.data?.message || 'حدث خطأ أثناء إنشاء الحساب');
      }
    },
  });

  return (
    <Box sx={{ maxWidth: 600, mx: 'auto', mt: 4 }}>
      <Paper sx={{ p: 4, borderRadius: 2 }}>
        <Typography variant="h5" color="primary" gutterBottom>
          إنشاء حساب جديد
        </Typography>

        <Box sx={{ borderBottom: 1, borderColor: 'divider', mb: 3 }}>
          <Tabs value={role} onChange={(_e, val) => setRole(val)}>
            <Tab label="إنشاء حساب معلم" value="teacher" />
            <Tab label="إنشاء حساب طالب" value="student" />
          </Tabs>
        </Box>

        {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

        <form onSubmit={formik.handleSubmit}>
          <TextField
            fullWidth
            margin="normal"
            id="name"
            name="name"
            label="الاسم الكامل"
            value={formik.values.name}
            onChange={formik.handleChange}
            error={formik.touched.name && Boolean(formik.errors.name)}
            helperText={formik.touched.name && formik.errors.name}
          />
          <TextField
            fullWidth
            margin="normal"
            id="phone"
            name="phone"
            label="رقم الهاتف"
            dir="ltr"
            slotProps={{ htmlInput: { style: { textAlign: 'right' } } }}
            value={formik.values.phone}
            onChange={formik.handleChange}
            error={formik.touched.phone && Boolean(formik.errors.phone)}
            helperText={formik.touched.phone && formik.errors.phone}
          />
          <TextField
            fullWidth
            margin="normal"
            id="password"
            name="password"
            label="كلمة المرور"
            type="password"
            value={formik.values.password}
            onChange={formik.handleChange}
            error={formik.touched.password && Boolean(formik.errors.password)}
            helperText={formik.touched.password && formik.errors.password}
          />
          <TextField
            fullWidth
            margin="normal"
            id="dob"
            name="dob"
            label="تاريخ الميلاد"
            type="date"
            slotProps={{ htmlInput: { shrink: 'true' } }}
            value={formik.values.dob}
            onChange={formik.handleChange}
            error={formik.touched.dob && Boolean(formik.errors.dob)}
            helperText={formik.touched.dob && formik.errors.dob}
          />

          <Button 
            color="primary" 
            variant="contained" 
            fullWidth 
            type="submit" 
            sx={{ mt: 3 }}
            disabled={formik.isSubmitting}
          >
            إنشاء حساب {role === 'teacher' ? 'معلم' : 'طالب'}
          </Button>
        </form>
      </Paper>

      <Snackbar 
        open={success} 
        autoHideDuration={6000} 
        onClose={() => setSuccess(false)}
        message="تم إنشاء الحساب بنجاح"
      />
    </Box>
  );
};

export default CreateAccount;
