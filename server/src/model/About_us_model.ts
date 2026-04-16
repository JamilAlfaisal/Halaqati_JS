import { Entity, PrimaryGeneratedColumn, Column } from "typeorm";

@Entity()
export class AboutUs {
    @PrimaryGeneratedColumn()
    id!: number;

    @Column({ type: "text" })
    contentAr!: string;

    @Column({ type: "text" })
    contentEn!: string;

    @Column({ nullable: true })
    linkedInUrl!: string;

    @Column({ nullable: true })
    contactPhone!: string;

    @Column({ default: "1.0.0" })
    version!: string;
}