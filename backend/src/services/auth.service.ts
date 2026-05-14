import User, { IUser } from "../models/user.model";
import { AppError } from "../utils/appError";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";

export class AuthService {
  private GENERATE_SALT_ROUNDS = 10;

  private JWT_SECRET = process.env.JWT_SECRET || ("jwt_secret" as jwt.Secret);
  private JWT_EXPIRES_IN = "24h" as jwt.SignOptions["expiresIn"];

  async register(
    email: string,
    password: string,
    role: "admin" | "user",
  ): Promise<IUser> {
    // find user in db
    const existingUser = await this.getUserByEmail(email);
    if (existingUser) {
      throw new AppError(409, "EMAIL_ALREADY_IN_USE", "Email already in use");
    }

    // hash password
    const hashedPassword = await this.hashPassword(password);

    // create new user
    const newUser = new User({ email, password: hashedPassword, role });
    await newUser.save();

    return newUser;
  }

  async login(email: string, password: string): Promise<string> {
    // find user in db
    const user = await this.getUserByEmail(email);
    if (!user) {
      throw new AppError(404, "USER_NOT_FOUND", "User not found");
    }

    // compare password
    const isMatch = await this.comparePassword(password, user.password);
    if (!isMatch) {
      throw new AppError(
        401,
        "INVALID_CREDENTIALS",
        "Invalid email or password",
      );
    }

    // generate JWT token
    const token = await this.generateJWT(user);

    return token;
  }

  async getUserByEmail(email: string): Promise<IUser | null> {
    return await User.findOne({ email });
  }

  private async hashPassword(password: string): Promise<string> {
    const salt = await bcrypt.genSalt(this.GENERATE_SALT_ROUNDS);
    return await bcrypt.hash(password, salt);
  }

  private async comparePassword(
    plainPassword: string,
    hashedPassword: string,
  ): Promise<boolean> {
    return await bcrypt.compare(plainPassword, hashedPassword);
  }

  async generateJWT(user: IUser): Promise<string> {
    return jwt.sign(
      { userId: user._id, email: user.email, role: user.role },
      this.JWT_SECRET,
      { expiresIn: this.JWT_EXPIRES_IN },
    );
  }
}
