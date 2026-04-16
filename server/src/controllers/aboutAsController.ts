import { Request, Response } from "express";
import { AppDataSource } from "../data-source";
import { AboutUs } from "../model/About_us_model";

export const getAboutUs = async (req: Request, res: Response) => {
    try {
        const aboutRepository = AppDataSource.getRepository(AboutUs);


        const aboutData = await aboutRepository.findOneBy({ id: 1 });

        if (!aboutData) {
            return res.status(404).json({ message: "About Us content not found." });
        }

        const { id, contentAr, contentEn, linkedInUrl, contactPhone, version } = aboutData;

        return res.status(200).json({
            id,
            arabicContent: contentAr,
            englishContent: contentEn,
            linkedInUrl: linkedInUrl,
            contactPhone: contactPhone,
            version: version
        });
    } catch (error) {
        console.error("Error fetching About Us:", error);
        return res.status(500).json({ message: "Internal server error" });
    }
};