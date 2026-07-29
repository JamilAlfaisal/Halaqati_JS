import React, { useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { useFormik } from 'formik';
import * as Yup from 'yup';
import {
  Box, Typography, Paper, TextField, Button, Checkbox, FormControlLabel,
  FormGroup, FormLabel, FormControl, MenuItem, Alert
} from '@mui/material';
import { createClass, updateClass, fetchAllTeachers } from '../redux/classesSlice';
import type { AppDispatch, RootState } from '../redux/store';
import apiClient from '../api/apiClient';

const DAYS_OPTIONS = [
  { value: 'السبت', label: 'السبت' },
  { value: 'الأحد', label: 'الأحد' },
  { value: 'الإثنين', label: 'الإثنين' },
  { value: 'الثلاثاء', label: 'الثلاثاء' },
  { value: 'الأربعاء', label: 'الأربعاء' },
  { value: 'الخميس', label: 'الخميس' },
  { value: 'الجمعة', label: 'الجمعة' },
];

const validationSchema = Yup.object({
  name: Yup.string().required('اسم الحلقة مطلوب'),
  teacherId: Yup.number().required('يجب اختيار المعلم').min(1, 'يجب اختيار المعلم'),
  days: Yup.array().min(1, 'يجب اختيار يوم واحد على الأقل'),
});

const ClassForm: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const isEdit = !!id;
  const navigate = useNavigate();
  const dispatch = useDispatch<AppDispatch>();
  const teachers = useSelector((state: RootState) => state.classes.teachers);

  useEffect(() => {
    dispatch(fetchAllTeachers());
  }, [dispatch]);

  // Pre-fill if editing
  useEffect(() => {
    if (isEdit) {
      apiClient.get(`/class/details/${id}`).then((res) => {
        const cls = res.data.class;
        formik.setValues({
          name: cls.name || '',
          description: cls.description || '',
          location: cls.location || '',
          startTime: cls.startTime || '',
          endTime: cls.endTime || '',
          days: cls.days || [],
          teacherId: cls.teacher?.id || 0,
        });
      }).catch(() => {});
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  const formik = useFormik({
    initialValues: {
      name: '',
      description: '',
      location: '',
      startTime: '',
      endTime: '',
      days: [] as string[],
      teacherId: 0,
    },
    validationSchema,
    onSubmit: async (values, { setStatus }) => {
      try {
        if (isEdit) {
          await dispatch(updateClass({ id: Number(id), data: values })).unwrap();
        } else {
          await dispatch(createClass(values)).unwrap();
        }
        navigate('/classes');
      } catch (err: any) {
        setStatus(err || 'حدث خطأ');
      }
    },
  });

  const handleDayToggle = (day: string) => {
    const current = formik.values.days;
    if (current.includes(day)) {
      formik.setFieldValue('days', current.filter(d => d !== day));
    } else {
      formik.setFieldValue('days', [...current, day]);
    }
  };

  return (
    <Box sx={{ maxWidth: 700, mx: 'auto' }}>
      <Paper sx={{ p: 4, borderRadius: 2 }}>
        <Typography variant="h5" color="primary" gutterBottom>
          {isEdit ? 'تعديل الحلقة' : 'إنشاء حلقة جديدة'}
        </Typography>

        {formik.status && <Alert severity="error" sx={{ mb: 2 }}>{formik.status}</Alert>}

        <form onSubmit={formik.handleSubmit}>
          <TextField
            fullWidth margin="normal"
            id="name" name="name" label="اسم الحلقة"
            value={formik.values.name}
            onChange={formik.handleChange}
            error={formik.touched.name && Boolean(formik.errors.name)}
            helperText={formik.touched.name && formik.errors.name}
          />

          <TextField
            select fullWidth margin="normal"
            id="teacherId" name="teacherId" label="المعلم"
            value={formik.values.teacherId}
            onChange={formik.handleChange}
            error={formik.touched.teacherId && Boolean(formik.errors.teacherId)}
            helperText={formik.touched.teacherId && formik.errors.teacherId}
          >
            <MenuItem value={0} disabled>اختر معلماً</MenuItem>
            {teachers.map((t) => (
              <MenuItem key={t.id} value={t.id}>{t.name}</MenuItem>
            ))}
          </TextField>

          <TextField
            fullWidth margin="normal"
            id="description" name="description" label="الوصف (اختياري)"
            multiline rows={2}
            value={formik.values.description}
            onChange={formik.handleChange}
          />

          <TextField
            fullWidth margin="normal"
            id="location" name="location" label="الموقع (اختياري)"
            value={formik.values.location}
            onChange={formik.handleChange}
          />

          <Box sx={{ display: 'flex', gap: 2 }}>
            <TextField
              fullWidth margin="normal"
              id="startTime" name="startTime" label="وقت البدء"
              type="time"
              slotProps={{ htmlInput: { step: 300 } }}
              value={formik.values.startTime}
              onChange={formik.handleChange}
            />
            <TextField
              fullWidth margin="normal"
              id="endTime" name="endTime" label="وقت الانتهاء"
              type="time"
              slotProps={{ htmlInput: { step: 300 } }}
              value={formik.values.endTime}
              onChange={formik.handleChange}
            />
          </Box>

          <FormControl
            component="fieldset"
            margin="normal"
            error={formik.touched.days && Boolean(formik.errors.days)}
            sx={{ width: '100%' }}
          >
            <FormLabel component="legend">أيام الدوام</FormLabel>
            <FormGroup row>
              {DAYS_OPTIONS.map((day) => (
                <FormControlLabel
                  key={day.value}
                  control={
                    <Checkbox
                      checked={formik.values.days.includes(day.value)}
                      onChange={() => handleDayToggle(day.value)}
                    />
                  }
                  label={day.label}
                />
              ))}
            </FormGroup>
            {formik.touched.days && formik.errors.days && (
              <Typography variant="caption" color="error">{formik.errors.days as string}</Typography>
            )}
          </FormControl>

          <Box sx={{ display: 'flex', gap: 2, mt: 3 }}>
            <Button
              variant="contained" color="primary"
              type="submit" disabled={formik.isSubmitting}
              fullWidth
            >
              {isEdit ? 'حفظ التعديلات' : 'إنشاء الحلقة'}
            </Button>
            <Button
              variant="outlined" color="inherit"
              onClick={() => navigate('/classes')}
              fullWidth
            >
              إلغاء
            </Button>
          </Box>
        </form>
      </Paper>
    </Box>
  );
};

export default ClassForm;
