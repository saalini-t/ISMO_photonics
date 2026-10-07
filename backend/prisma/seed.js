const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function main() {
  const passwordHash = await bcrypt.hash('password123', 10);

  // User 1
  const user1 = await prisma.user.create({
    data: {
      email: 'john.doe@example.com',
      fullName: 'John Doe',
      password: passwordHash,
      projects: {
        create: [
          {
            name: 'Website Redesign',
            description: 'Redesigning the corporate website.',
            status: 'IN_PROGRESS',
            tasks: {
              create: [
                { name: 'Wireframing', priority: 'HIGH', status: 'COMPLETED' },
                { name: 'Mockups', priority: 'MEDIUM', status: 'IN_PROGRESS' },
                { name: 'Frontend Dev', priority: 'HIGH', status: 'PENDING' },
              ]
            }
          },
          {
            name: 'Mobile App V2',
            description: 'Building version 2 of the mobile app.',
            status: 'NOT_STARTED',
            tasks: {
              create: [
                { name: 'Requirements', priority: 'HIGH', status: 'PENDING' },
                { name: 'Design', priority: 'MEDIUM', status: 'PENDING' },
                { name: 'Backend API', priority: 'HIGH', status: 'PENDING' },
              ]
            }
          },
          {
            name: 'SEO Optimization',
            description: 'Improving SEO rankings.',
            status: 'COMPLETED',
            tasks: {
              create: [
                { name: 'Keyword Research', priority: 'MEDIUM', status: 'COMPLETED' },
                { name: 'On-page SEO', priority: 'HIGH', status: 'COMPLETED' },
                { name: 'Backlinks', priority: 'LOW', status: 'COMPLETED' },
              ]
            }
          }
        ]
      }
    }
  });

  // User 2
  const user2 = await prisma.user.create({
    data: {
      email: 'jane.smith@example.com',
      fullName: 'Jane Smith',
      password: passwordHash,
      projects: {
        create: [
          {
            name: 'Marketing Campaign Q3',
            description: 'Q3 marketing strategies and execution.',
            status: 'IN_PROGRESS',
            tasks: {
              create: [
                { name: 'Social Media Ads', priority: 'HIGH', status: 'IN_PROGRESS' },
                { name: 'Email Newsletter', priority: 'MEDIUM', status: 'PENDING' },
                { name: 'Blog Posts', priority: 'LOW', status: 'COMPLETED' },
              ]
            }
          },
          {
            name: 'Internal Tools Migration',
            description: 'Migrating internal tools to new stack.',
            status: 'NOT_STARTED',
            tasks: {
              create: [
                { name: 'Audit', priority: 'HIGH', status: 'PENDING' },
                { name: 'Vendor Selection', priority: 'MEDIUM', status: 'PENDING' },
                { name: 'Data Migration', priority: 'HIGH', status: 'PENDING' },
              ]
            }
          },
          {
            name: 'Customer Survey',
            description: 'Annual customer satisfaction survey.',
            status: 'COMPLETED',
            tasks: {
              create: [
                { name: 'Draft Questions', priority: 'MEDIUM', status: 'COMPLETED' },
                { name: 'Send Emails', priority: 'HIGH', status: 'COMPLETED' },
                { name: 'Analyze Results', priority: 'HIGH', status: 'COMPLETED' },
              ]
            }
          }
        ]
      }
    }
  });

  console.log('Seed completed successfully!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
