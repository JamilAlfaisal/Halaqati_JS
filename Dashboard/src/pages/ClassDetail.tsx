import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { Box, Typography, Paper, Tabs, Tab, Button } from '@mui/material';
import DownloadIcon from '@mui/icons-material/Download';
import { DatePicker } from '@mui/x-date-pickers/DatePicker';
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider';
import { AdapterDayjs } from '@mui/x-date-pickers/AdapterDayjs';
import dayjs, { Dayjs } from 'dayjs';
import apiClient from '../api/apiClient';
import AttendanceTab from '../components/AttendanceTab';
import GradesTab from '../components/GradesTab';
import PageProgressTab from '../components/PageProgressTab';

interface TabPanelProps {
  children?: React.ReactNode;
  index: number;
  value: number;
}

function CustomTabPanel(props: TabPanelProps) {
  const { children, value, index, ...other } = props;
  return (
    <div role="tabpanel" hidden={value !== index} {...other}>
      {value === index && (
        <Box sx={{ p: 3 }}>
          {children}
        </Box>
      )}
    </div>
  );
}

const ClassDetail: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const [classDetails, setClassDetails] = useState<any>(null);
  const [tabValue, setTabValue] = useState(0);
  
  // Hoist date state here so Export can use it
  const [startDate, setStartDate] = useState<Dayjs | null>(dayjs().subtract(30, 'day'));
  const [endDate, setEndDate] = useState<Dayjs | null>(dayjs());

  useEffect(() => {
    const fetchDetails = async () => {
      try {
        const response = await apiClient.get(`/class/details/${id}`);
        setClassDetails(response.data.class);
      } catch (err) {
        console.error("Failed to fetch class details");
      }
    };
    if (id) fetchDetails();
  }, [id]);

  const handleExportExcel = async () => {
    if (!id || !startDate || !endDate) return;
    try {
      const startStr = startDate.format('YYYY-MM-DD');
      const endStr = endDate.format('YYYY-MM-DD');
      
      const response = await apiClient.get(
        `/class/admin/export/${id}?startDate=${startStr}&endDate=${endStr}`,
        { responseType: 'blob' }
      );
      
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      
      const cleanClassName = (classDetails?.name || 'Class').replace(/[\/\\?%*:|"<>\s]/g, '-');
      const exportDate = dayjs().format('YYYY-MM-DD');
      link.setAttribute('download', `${cleanClassName}_${exportDate}.xlsx`);
      
      document.body.appendChild(link);
      link.click();
      link.parentNode?.removeChild(link);
    } catch (err) {
      console.error("Failed to export Excel", err);
    }
  };

  if (!classDetails) return <Typography>جاري التحميل...</Typography>;

  return (
    <LocalizationProvider dateAdapter={AdapterDayjs}>
      <Box>
        <Paper sx={{ p: 3, mb: 3, borderRadius: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: 2 }}>
          <Box>
            <Typography variant="h4" color="primary" gutterBottom>
              {classDetails.name}
            </Typography>
            <Typography variant="body1">
              <strong>المعلم:</strong> {classDetails.teacher?.name}
            </Typography>
            <Typography variant="body1">
              <strong>الوصف:</strong> {classDetails.description || 'لا يوجد'}
            </Typography>
          </Box>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, alignItems: 'flex-end' }}>
            <Box sx={{ display: 'flex', gap: 2 }}>
              <DatePicker
                label="من تاريخ"
                value={startDate}
                onChange={(newValue) => setStartDate(newValue)}
                format="YYYY-MM-DD"
              />
              <DatePicker
                label="إلى تاريخ"
                value={endDate}
                onChange={(newValue) => setEndDate(newValue)}
                format="YYYY-MM-DD"
              />
            </Box>
            <Button 
              variant="contained" 
              color="secondary" 
              startIcon={<DownloadIcon />}
              onClick={handleExportExcel}
              disabled={!startDate || !endDate}
            >
              تصدير إلى Excel
            </Button>
          </Box>
        </Paper>

        <Paper sx={{ width: '100%', borderRadius: 2 }}>
          <Box sx={{ borderBottom: 1, borderColor: 'divider' }}>
            <Tabs value={tabValue} onChange={(_e, newValue) => setTabValue(newValue)}>
              <Tab label="الحضور" />
              <Tab label="الدرجات" />
              <Tab label="إنجاز الصفحات" />
            </Tabs>
          </Box>
          <CustomTabPanel value={tabValue} index={0}>
            <AttendanceTab classId={Number(id)} startDate={startDate} endDate={endDate} />
          </CustomTabPanel>
          <CustomTabPanel value={tabValue} index={1}>
            <GradesTab classId={Number(id)} startDate={startDate} endDate={endDate} />
          </CustomTabPanel>
          <CustomTabPanel value={tabValue} index={2}>
            <PageProgressTab classId={Number(id)} />
          </CustomTabPanel>
        </Paper>
      </Box>
    </LocalizationProvider>
  );
};

export default ClassDetail;
