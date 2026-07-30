import { AppDataSource } from "./data-source";
import { User } from "./model/User";
import { hashPassword } from "./utils/auth";
import * as dotenv from "dotenv";

dotenv.config();

async function seedAdmin() {
  await AppDataSource.initialize();
  const userRepository = AppDataSource.getRepository(User);

  const adminPhone = process.argv[2] || "0000000000";
  const adminPassword = process.argv[3] || "admin123";
  const adminName = process.argv[4] || "Super Admin";

  const existingAdmin = await userRepository.findOne({ where: { role: "admin" } });
  if (existingAdmin) {
    console.log("An admin already exists. Seed aborted.");
    process.exit(0);
  }
 
  const existingUser = await userRepository.findOne({ where: { phone: adminPhone } });
  if (existingUser) {
    console.log(`User with phone ${adminPhone} already exists. Pick another phone.`);
    process.exit(1);
  }

  const hashedPassword = await hashPassword(adminPassword);
  
  const admin = userRepository.create({
    name: adminName,
    email: "admin@halaqati.com",
    password: hashedPassword,
    phone: adminPhone,
    dob: new Date("1990-01-01"),
    role: "admin",
  });

  await userRepository.save(admin);
  console.log(`Admin created successfully!\nPhone: ${adminPhone}\nPassword: ${adminPassword}`);
  process.exit(0);
}

seedAdmin().catch(error => {
  console.error("Error seeding admin:", error);
  process.exit(1);
});
