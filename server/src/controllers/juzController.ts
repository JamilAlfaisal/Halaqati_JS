import {Response} from 'express';
import { AppDataSource  } from '../data-source';
import { Student } from '../model/Student';
import { StudyIn } from '../model/Study_in';
import { AuthRequest } from '../middleware/middleware';

export const updateMemorizedJuz = async(req:AuthRequest, res: Response) => {
    const studyInRepository = AppDataSource.getRepository(StudyIn);
    const studentRepository = AppDataSource.getRepository(Student);

    try{
        const userId = req.user?.id;
        const role = req.user?.role;
        const studentId = Number(req.params.id);
        const memorizedJuz = req.body.memorized_juz;

        if (!userId) {
            console.log("❌ http://localhost:3000/api/update_student/juz");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if(role != "teacher"){
            console.log("❌ http://localhost:3000/api/update_student/juz");
            return res.status(403).json({message:"Forbidden"})
        }

        if (isNaN(studentId)){
            console.log("❌ http://localhost:3000/api/update_student/juz");
            return res.status(400).json({message:"Invalid class id"});
        }

        if (
            !Array.isArray(memorizedJuz) ||
            memorizedJuz.length > 30
            ) {
            return res.status(400).json({
                message: "memorized_juz must be an array of numbers between 1 and 30"
            });
            }


        const studyIn = await studyInRepository.find({
            where: {
                student: {id: studentId}
            },
            relations: ['student', 'class', 'class.teacher']
        });

        const isHisStudent = studyIn.some(inn => inn.class.teacher.id === userId);

        if(!isHisStudent){
            console.log("❌ http://localhost:3000/api/update_student/juz");
            return res.status(403).json({message:'You can only edit information for students enrolled in your classes.'})
        }

        const student = await studentRepository.findOneBy({id: studentId});

        if (!student){
            console.log("❌ http://localhost:3000/api/update_student/juz");
            return res.status(404).json({message:'Student not found'});
        }

        student.memorized_juz = memorizedJuz;

        await studentRepository.save(student)

        console.log("✅ http://localhost:3000/api/update_student/juz");
        return res.status(200).json({
            studentId: student.id,
            memorized_juz: student.memorized_juz
        })

    }catch(e){
        console.log("❌ http://localhost:3000/api/update_student/juz");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Faild to update memorized juz" });
    }
}